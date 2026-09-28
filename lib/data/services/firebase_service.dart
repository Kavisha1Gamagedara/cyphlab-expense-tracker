import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants.dart';
import '../models/expense_model.dart';

/// Service responsible for Firestore operations (CRUD).
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

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.expensesCollection);

  /// Real-time stream of expenses ordered by date descending
  Stream<List<Expense>> getExpensesStream() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromDocument(doc)).toList();
    });
  }

  /// Add a new expense document to Firestore
  Future<String> addExpense(Expense expense) async {
    try {
      debugPrint('[FirebaseService] Adding expense: ${expense.toMap()}');
      final docRef = await _collection
          .add(expense.toMap())
          .timeout(const Duration(seconds: 15));
      debugPrint('[FirebaseService] Added expense successfully with id: ${docRef.id}');
      return docRef.id;
    } catch (e, stack) {
      debugPrint('[FirebaseService] Error adding expense: $e\n$stack');
      throw Exception('Failed to add expense: $e');
    }
  }

  /// Update an existing expense document in Firestore
  Future<void> updateExpense(Expense expense) async {
    try {
      if (expense.id.isEmpty) {
        throw ArgumentError('Expense ID cannot be empty during update');
      }
      await _collection.doc(expense.id).update(expense.toMap());
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  /// Delete an expense document by ID
  Future<void> deleteExpense(String expenseId) async {
    try {
      if (expenseId.isEmpty) {
        throw ArgumentError('Expense ID cannot be empty during deletion');
      }
      await _collection.doc(expenseId).delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
