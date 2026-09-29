import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/firebase_service.dart';

/// Manages expense data, filtering, calculations, and loading/error states.
class ExpenseProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  StreamSubscription<List<Expense>>? _expenseSubscription;

  List<Expense> _expenses = [];
  Map<String, MonthBudgetData> _budgets = {}; // 'yyyy_MM' -> MonthBudgetData
  StreamSubscription<Map<String, MonthBudgetData>>? _budgetSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate; // optional single date filter

  ExpenseProvider({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  // Getters
  /// All active (non-deleted) expenses
  List<Expense> get allExpenses => _expenses.where((e) => !e.isDeleted).toList();

  /// All expenses in the Recycle Bin (deleted within retention window)
  List<Expense> get recycledExpenses =>
      _expenses.where((e) => e.isDeleted).toList()
        ..sort((a, b) => (b.deletedAt ?? b.date).compareTo(a.deletedAt ?? a.date));

  /// Count of recycled items
  int get recycledCount => recycledExpenses.length;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  DateTime get selectedMonth => _selectedMonth;
  DateTime? get selectedDate => _selectedDate;

  /// Key for budget map: 'yyyy_MM'
  String get _currentMonthKey =>
      '${_selectedMonth.year}_${_selectedMonth.month.toString().padLeft(2, '0')}';

  /// Budget data (overall + category targets) for the selected month
  MonthBudgetData get currentMonthBudgetData =>
      _budgets[_currentMonthKey] ?? const MonthBudgetData();

  /// Budget limit for the currently selected month (or null if none set)
  double? get currentMonthBudget {
    final b = _budgets[_currentMonthKey];
    if (b == null || b.totalBudget <= 0) return null;
    return b.totalBudget;
  }

  /// Map of category budgets for the currently selected month
  Map<String, double> get currentMonthCategoryBudgets =>
      currentMonthBudgetData.categoryBudgets;

  /// Get spending limit for a specific category in the selected month
  double? getCategoryBudget(String category) =>
      currentMonthBudgetData.getCategoryBudget(category);

  /// Check if the currently filtered category has its own budget limit
  bool get hasSelectedCategoryBudget {
    if (_selectedCategory == 'All') return currentMonthBudget != null;
    return getCategoryBudget(_selectedCategory) != null;
  }

  /// Active budget limit depending on current filter (Overall if All, or Category limit)
  double? get activeContextBudget {
    if (_selectedCategory != 'All') {
      return getCategoryBudget(_selectedCategory);
    }
    return currentMonthBudget;
  }

  /// Total days in the selected month
  int get daysInSelectedMonth => DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
      ).day;

  /// Daily expenses for each day of the selected month (dayNumber to dayExpenseTotal)
  Map<int, double> get dailyExpensesInSelectedMonth {
    final map = {for (int i = 1; i <= daysInSelectedMonth; i++) i: 0.0};
    for (final exp in allExpenses) {
      if (exp.date.year == _selectedMonth.year && exp.date.month == _selectedMonth.month) {
        final day = exp.date.day;
        if (map.containsKey(day)) {
          map[day] = (map[day] ?? 0.0) + exp.amount;
        }
      }
    }
    return map;
  }

  /// Cumulative spending progression for each day of the selected month (dayNumber to cumulativeSum)
  Map<int, double> get cumulativeExpensesInSelectedMonth {
    final daily = dailyExpensesInSelectedMonth;
    final map = <int, double>{};
    double running = 0.0;
    final now = DateTime.now();
    final maxDay = (_selectedMonth.year == now.year && _selectedMonth.month == now.month)
        ? now.day
        : (_selectedMonth.isBefore(DateTime(now.year, now.month)) ? daysInSelectedMonth : 0);

    for (int day = 1; day <= daysInSelectedMonth; day++) {
      if (day <= maxDay || maxDay == 0 && daily[day]! > 0) {
        running += daily[day] ?? 0.0;
        map[day] = running;
      }
    }
    return map;
  }

  /// Check if the selected month is the current calendar month
  bool get isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  /// Filtered list of expenses based on selected category, search query, and selected month / date
  List<Expense> get filteredExpenses {
    return allExpenses.where((expense) {
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
    return allExpenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum for the selected month
  double get selectedMonthTotal {
    return allExpenses.where((expense) {
      return expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum for the selected single date (if a day is selected)
  double get selectedDateTotal {
    if (_selectedDate == null) return selectedMonthTotal;
    return allExpenses.where((expense) {
      return expense.date.year == _selectedDate!.year &&
          expense.date.month == _selectedDate!.month &&
          expense.date.day == _selectedDate!.day;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total sum for the current month
  double get currentMonthTotal {
    final now = DateTime.now();
    return allExpenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Breakdown of totals grouped by category for the selected month (unbiased by category chip filter)
  Map<String, double> get monthCategoryBreakdown {
    final map = <String, double>{};
    final monthExpenses = allExpenses.where((expense) {
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

  /// Subscribe to Firestore expense & budget streams
  void startListening() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[ExpenseProvider] Subscribing to getExpensesStream & getBudgetsStream...');
      _expenseSubscription?.cancel();
      _expenseSubscription = _firebaseService.getExpensesStream().listen(
        (expensesList) {
          debugPrint('[ExpenseProvider] Received ${expensesList.length} expenses from Firestore');
          _expenses = expensesList;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
          // Purge any expenses soft-deleted more than 5 days ago
          autoPurgeExpiredRecycledExpenses();
        },
        onError: (error) {
          debugPrint('[ExpenseProvider] Stream error: $error');
          _isLoading = false;
          _errorMessage = error.toString();
          notifyListeners();
        },
      );

      _budgetSubscription?.cancel();
      _budgetSubscription = _firebaseService.getBudgetsStream().listen(
        (budgetMap) {
          debugPrint('[ExpenseProvider] Received ${budgetMap.length} budgets from Firestore');
          _budgets = budgetMap;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('[ExpenseProvider] Budget stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('[ExpenseProvider] Exception during startListening: $e');
      _isLoading = false;
      _errorMessage = 'Firebase error: $e';
      notifyListeners();
    }
  }

  /// Set or update the overall budget limit for the selected month
  Future<bool> setMonthlyBudget(double amount) async {
    try {
      await _firebaseService.setBudget(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
        amount: amount,
      );
      final current = _budgets[_currentMonthKey] ?? const MonthBudgetData();
      _budgets[_currentMonthKey] = current.copyWith(totalBudget: amount);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ExpenseProvider] Error setting budget: $e');
      return false;
    }
  }

  /// Set or update a category-specific spending limit for the selected month
  Future<bool> setCategoryBudget(String category, double amount) async {
    try {
      await _firebaseService.setCategoryBudget(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
        category: category,
        amount: amount,
      );
      final current = _budgets[_currentMonthKey] ?? const MonthBudgetData();
      final updatedCategories = Map<String, double>.from(current.categoryBudgets);
      if (amount <= 0) {
        updatedCategories.remove(category);
      } else {
        updatedCategories[category] = amount;
      }
      _budgets[_currentMonthKey] = current.copyWith(categoryBudgets: updatedCategories);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ExpenseProvider] Error setting category budget: $e');
      return false;
    }
  }

  /// Remove a category-specific spending limit
  Future<bool> removeCategoryBudget(String category) =>
      setCategoryBudget(category, 0);

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

  /// Move an expense to the Recycle Bin (soft delete for 5 days)
  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _firebaseService.moveToRecycleBin(expenseId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Restore an expense from the Recycle Bin back to active expenses
  Future<bool> restoreExpense(String expenseId) async {
    try {
      await _firebaseService.restoreExpense(expenseId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Permanently delete an expense forever
  Future<bool> permanentlyDeleteExpense(String expenseId) async {
    try {
      await _firebaseService.permanentlyDeleteExpense(expenseId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Empty all items currently in the Recycle Bin permanently
  Future<bool> emptyRecycleBin() async {
    try {
      final ids = recycledExpenses.map((e) => e.id).toList();
      await _firebaseService.permanentlyDeleteExpenses(ids);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Automatically purge deleted items that have exceeded the 5-day retention threshold
  Future<void> autoPurgeExpiredRecycledExpenses() async {
    final now = DateTime.now();
    const retentionDuration = Duration(days: 5);
    final expiredIds = <String>[];

    for (final exp in recycledExpenses) {
      final deletedTimestamp = exp.deletedAt;
      if (deletedTimestamp != null) {
        if (now.difference(deletedTimestamp) > retentionDuration) {
          expiredIds.add(exp.id);
        }
      }
    }

    if (expiredIds.isNotEmpty) {
      debugPrint('[ExpenseProvider] Purging ${expiredIds.length} expired items older than 5 days');
      try {
        await _firebaseService.permanentlyDeleteExpenses(expiredIds);
      } catch (e) {
        debugPrint('[ExpenseProvider] Failed to auto-purge expired items: $e');
      }
    }
  }

  /// Clear data on user logout
  void clearData() {
    _expenseSubscription?.cancel();
    _expenseSubscription = null;
    _budgetSubscription?.cancel();
    _budgetSubscription = null;
    _expenses = [];
    _budgets = {};
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
    _budgetSubscription?.cancel();
    super.dispose();
  }
}
