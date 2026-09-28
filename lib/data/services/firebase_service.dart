import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants.dart';
import '../models/expense_model.dart';

/// Service responsible for Firestore operations (CRUD), scoped to the authenticated user.
class FirebaseService {
  final FirebaseFirestore _firestore;

  FirebaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    // Explicitly configure settings for mobile reliability
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Get current user ID or throw exception if unauthenticated
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Firestore subcollection path: users/{userId}/expenses
  CollectionReference<Map<String, dynamic>> _userExpensesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(AppConstants.expensesCollection);
  }

  /// Real-time stream of expenses for the authenticated user, ordered by date descending
  Stream<List<Expense>> getExpensesStream() {
    final uid = _currentUserId;
    if (uid == null) {
      debugPrint('[FirebaseService] getExpensesStream: No user logged in, returning empty stream');
      return Stream.value([]);
    }

    return _userExpensesRef(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromDocument(doc)).toList();
    });
  }

  /// Add a new expense document for current user
  Future<String> addExpense(Expense expense) async {
    final uid = _currentUserId;
    if (uid == null) {
      throw Exception('Cannot add expense: No authenticated user.');
    }

    try {
      debugPrint('[FirebaseService] Adding expense for user $uid: ${expense.toMap()}');
      final docRef = await _userExpensesRef(uid)
          .add(expense.toMap())
          .timeout(const Duration(seconds: 15));
      debugPrint('[FirebaseService] Added expense successfully with id: ${docRef.id}');
      return docRef.id;
    } catch (e, stack) {
      debugPrint('[FirebaseService] Error adding expense: $e\n$stack');
      throw Exception('Failed to add expense: $e');
    }
  }

  /// Update an existing expense document
  Future<void> updateExpense(Expense expense) async {
    final uid = _currentUserId;
    if (uid == null) {
      throw Exception('Cannot update expense: No authenticated user.');
    }
    if (expense.id.isEmpty) {
      throw ArgumentError('Expense ID cannot be empty during update');
    }

    try {
      await _userExpensesRef(uid).doc(expense.id).update(expense.toMap());
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Move an expense document to Recycle Bin (soft delete)
  Future<void> moveToRecycleBin(String expenseId) async {
    final uid = _currentUserId;
    if (uid == null) {
      throw Exception('Cannot delete expense: No authenticated user.');
    }
    if (expenseId.isEmpty) {
      throw ArgumentError('Expense ID cannot be empty');
    }

    try {
      await _userExpensesRef(uid).doc(expenseId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to move expense to recycle bin: $e');
    }
  }

  /// Restore an expense from Recycle Bin back to active expenses
  Future<void> restoreExpense(String expenseId) async {
    final uid = _currentUserId;
    if (uid == null) {
      throw Exception('Cannot restore expense: No authenticated user.');
    }
    if (expenseId.isEmpty) {
      throw ArgumentError('Expense ID cannot be empty');
    }

    try {
      await _userExpensesRef(uid).doc(expenseId).update({
        'isDeleted': false,
        'deletedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to restore expense: $e');
    }
  }

  /// Permanently delete an expense document by ID from Firestore
  Future<void> permanentlyDeleteExpense(String expenseId) async {
    final uid = _currentUserId;
    if (uid == null) {
      throw Exception('Cannot delete expense: No authenticated user.');
    }
    if (expenseId.isEmpty) {
      throw ArgumentError('Expense ID cannot be empty during deletion');
    }

    try {
      await _userExpensesRef(uid).doc(expenseId).delete();
    } catch (e) {
      throw Exception('Failed to permanently delete expense: $e');
    }
  }

  /// Permanently delete multiple expenses (e.g. Empty Bin or purge expired)
  Future<void> permanentlyDeleteExpenses(List<String> expenseIds) async {
    final uid = _currentUserId;
    if (uid == null || expenseIds.isEmpty) return;

    try {
      final batch = _firestore.batch();
      for (final id in expenseIds) {
        batch.delete(_userExpensesRef(uid).doc(id));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete expenses: $e');
    }
  }

  /// Backward compatible deleteExpense method that soft-deletes to recycle bin
  Future<void> deleteExpense(String expenseId) => moveToRecycleBin(expenseId);

  /// Reference to budgets subcollection: users/{userId}/budgets
  CollectionReference<Map<String, dynamic>> _userBudgetsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('budgets');
  }

  /// Save or update spending limit/budget for a given year and month (key: 'yyyy_MM')
  Future<void> setBudget({required int year, required int month, required double amount}) async {
    final uid = _currentUserId;
    if (uid == null) return;
    final key = '${year}_${month.toString().padLeft(2, '0')}';
    await _userBudgetsRef(uid).doc(key).set({
      'amount': amount,
      'year': year,
      'month': month,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Real-time stream of all user budgets mapped by 'yyyy_MM' -> limit amount
  Stream<Map<String, double>> getBudgetsStream() {
    final uid = _currentUserId;
    if (uid == null) return Stream.value({});
    return _userBudgetsRef(uid).snapshots().map((snapshot) {
      final map = <String, double>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['amount'] is num) {
          map[doc.id] = (data['amount'] as num).toDouble();
        }
      }
      return map;
    });
  }
}
