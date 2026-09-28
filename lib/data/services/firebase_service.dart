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

  /// Delete an expense document by ID
  Future<void> deleteExpense(String expenseId) async {
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
      throw Exception('Failed to delete expense: $e');
    }
  }
}
