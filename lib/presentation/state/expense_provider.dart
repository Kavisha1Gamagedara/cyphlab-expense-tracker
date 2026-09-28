import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/firebase_service.dart';

/// Manages expense data, filtering, calculations, and loading/error states.
class ExpenseProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  StreamSubscription<List<Expense>>? _expenseSubscription;

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  ExpenseProvider({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  // Getters
  List<Expense> get allExpenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Filtered list of expenses based on selected category and search query
  List<Expense> get filteredExpenses {
    return _expenses.where((expense) {
      final matchesCategory =
          _selectedCategory == 'All' || expense.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (expense.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Total sum of all expenses
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum for the current month
  double get currentMonthTotal {
    final now = DateTime.now();
    return _expenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Breakdown of totals grouped by category
  Map<String, double> get categoryBreakdown {
    final map = <String, double>{};
    for (final expense in _expenses) {
      map[expense.category] = (map[expense.category] ?? 0.0) + expense.amount;
    }
    return map;
  }

  /// Subscribe to Firestore expense stream
  void startListening() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenseSubscription?.cancel();
      _expenseSubscription = _firebaseService.getExpensesStream().listen(
        (expensesList) {
          _expenses = expensesList;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          _errorMessage = error.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Firebase not yet configured: $e';
      notifyListeners();
    }
  }

  /// Set category filter
  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  /// Set search query filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Add new expense
  Future<bool> addExpense(Expense expense) async {
    try {
      await _firebaseService.addExpense(expense);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update existing expense
  Future<bool> updateExpense(Expense expense) async {
    try {
      await _firebaseService.updateExpense(expense);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete an expense
  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _firebaseService.deleteExpense(expenseId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}
