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
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate; // optional single date filter

  ExpenseProvider({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  // Getters
  List<Expense> get allExpenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  DateTime get selectedMonth => _selectedMonth;
  DateTime? get selectedDate => _selectedDate;

  /// Check if the selected month is the current calendar month
  bool get isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  /// Filtered list of expenses based on selected category, search query, and selected month / date
  List<Expense> get filteredExpenses {
    return _expenses.where((expense) {
      final matchesCategory =
          _selectedCategory == 'All' || expense.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (expense.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      bool matchesDateFilter;
      if (_selectedDate != null) {
        matchesDateFilter = expense.date.year == _selectedDate!.year &&
            expense.date.month == _selectedDate!.month &&
            expense.date.day == _selectedDate!.day;
      } else {
        matchesDateFilter = expense.date.year == _selectedMonth.year &&
            expense.date.month == _selectedMonth.month;
      }

      return matchesCategory && matchesSearch && matchesDateFilter;
    }).toList();
  }

  /// Total sum of all expenses across all time
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum for the selected month
  double get selectedMonthTotal {
    return _expenses.where((expense) {
      return expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum for the selected single date (if a day is selected)
  double get selectedDateTotal {
    if (_selectedDate == null) return selectedMonthTotal;
    return _expenses.where((expense) {
      return expense.date.year == _selectedDate!.year &&
          expense.date.month == _selectedDate!.month &&
          expense.date.day == _selectedDate!.day;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum for the current month
  double get currentMonthTotal {
    final now = DateTime.now();
    return _expenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Breakdown of totals grouped by category for the selected month (unbiased by category chip filter)
  Map<String, double> get monthCategoryBreakdown {
    final map = <String, double>{};
    final monthExpenses = _expenses.where((expense) {
      if (_selectedDate != null) {
        return expense.date.year == _selectedDate!.year &&
            expense.date.month == _selectedDate!.month &&
            expense.date.day == _selectedDate!.day;
      }
      return expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;
    });

    for (final expense in monthExpenses) {
      map[expense.category] = (map[expense.category] ?? 0.0) + expense.amount;
    }
    return map;
  }

  /// Breakdown of totals grouped by category for current filtered expenses
  Map<String, double> get categoryBreakdown {
    final map = <String, double>{};
    for (final expense in filteredExpenses) {
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
      debugPrint('[ExpenseProvider] Subscribing to getExpensesStream...');
      _expenseSubscription?.cancel();
      _expenseSubscription = _firebaseService.getExpensesStream().listen(
        (expensesList) {
          debugPrint('[ExpenseProvider] Received ${expensesList.length} expenses from Firestore');
          _expenses = expensesList;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('[ExpenseProvider] Stream error: $error');
          _isLoading = false;
          _errorMessage = error.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('[ExpenseProvider] Exception during startListening: $e');
      _isLoading = false;
      _errorMessage = 'Firebase error: $e';
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

  /// Set selected month (year + month)
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    _selectedDate = null; // Clear specific day selection when switching months
    notifyListeners();
  }

  /// Set specific date filter within or across months
  void setSelectedDate(DateTime? date) {
    if (date != null) {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _selectedMonth = DateTime(date.year, date.month);
    } else {
      _selectedDate = null;
    }
    notifyListeners();
  }

  /// Clear the single-day date filter back to entire month
  void clearDateFilter() {
    if (_selectedDate != null) {
      _selectedDate = null;
      notifyListeners();
    }
  }

  /// Navigate to the previous month
  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    _selectedDate = null;
    notifyListeners();
  }

  /// Navigate to the next month
  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    _selectedDate = null;
    notifyListeners();
  }

  /// Reset to current calendar month
  void resetToCurrentMonth() {
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _selectedDate = null;
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

  /// Clear data on user logout
  void clearData() {
    _expenseSubscription?.cancel();
    _expenseSubscription = null;
    _expenses = [];
    _isLoading = false;
    _errorMessage = null;
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _selectedDate = null;
    _selectedCategory = 'All';
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}
