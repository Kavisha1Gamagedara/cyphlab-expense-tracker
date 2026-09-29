/// Represents the spending budget limits for a given month,
/// including the overall target and category-specific targets.
class MonthBudgetData {
  /// Overall budget for all expenses in the month (0.0 if not set)
  final double totalBudget;

  /// Map of category name -> spending limit for that category
  final Map<String, double> categoryBudgets;

  const MonthBudgetData({
    this.totalBudget = 0.0,
    this.categoryBudgets = const {},
  });

  /// Check if an overall budget limit is set
  bool get hasTotalBudget => totalBudget > 0;

  /// Check if any category has a budget limit set
  bool get hasAnyCategoryBudget => categoryBudgets.isNotEmpty;

  /// Get budget for a specific category (or null if not set)
  double? getCategoryBudget(String category) {
    final val = categoryBudgets[category];
    return (val != null && val > 0) ? val : null;
  }

  /// Total sum of all individual category budgets
  double get totalAllocatedCategoryBudget {
    return categoryBudgets.values.fold(0.0, (sum, val) => sum + val);
  }

  MonthBudgetData copyWith({
    double? totalBudget,
    Map<String, double>? categoryBudgets,
  }) {
    return MonthBudgetData(
      totalBudget: totalBudget ?? this.totalBudget,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }
}
