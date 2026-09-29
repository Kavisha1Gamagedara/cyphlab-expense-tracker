import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../state/expense_provider.dart';
import '../state/language_provider.dart';

/// Modal bottom sheet allowing users to set, edit, or remove both
/// the Overall Monthly Budget (for all expenses) and Category-wise Budget Limits.
class BudgetSettingsSheet extends StatefulWidget {
  final String? initialCategory;

  const BudgetSettingsSheet({super.key, this.initialCategory});

  static Future<void> show(BuildContext context, {String? initialCategory}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetSettingsSheet(initialCategory: initialCategory),
    );
  }

  @override
  State<BudgetSettingsSheet> createState() => _BudgetSettingsSheetState();
}

class _BudgetSettingsSheetState extends State<BudgetSettingsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _overallController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Default to category tab if an initial category was selected
    final initialIndex = widget.initialCategory != null ? 1 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);

    final provider = context.read<ExpenseProvider>();
    final currentOverall = provider.currentMonthBudget;
    _overallController = TextEditingController(
      text: currentOverall != null && currentOverall > 0
          ? (currentOverall % 1 == 0
              ? currentOverall.toStringAsFixed(0)
              : currentOverall.toStringAsFixed(2))
          : '',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _overallController.dispose();
    super.dispose();
  }

  void _showCategoryLimitDialog(
    BuildContext context,
    String category,
    ExpenseProvider provider,
    LanguageProvider lang,
  ) {
    final currentLimit = provider.getCategoryBudget(category);
    final categorySpent = provider.monthCategoryBreakdown[category] ?? 0.0;
    final catController = TextEditingController(
      text: currentLimit != null && currentLimit > 0
          ? (currentLimit % 1 == 0
              ? currentLimit.toStringAsFixed(0)
              : currentLimit.toStringAsFixed(2))
          : '',
    );

    final catColor = AppConstants.getCategoryColor(category);
    final catIcon = AppConstants.getCategoryIcon(category);
    final catName = lang.getCategory(category);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(catIcon, color: catColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${lang.getText('category_limit')} • ${DateFormat('MMM yyyy').format(provider.selectedMonth)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${lang.getText('total_spending')}:',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: AppConstants.defaultCurrency,
                      decimalDigits: categorySpent % 1 == 0 ? 0 : 2,
                    ).format(categorySpent),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: catController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: lang.getText('category_limit'),
                prefixText: '${AppConstants.defaultCurrency} ',
                hintText: 'e.g. 250.00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          if (currentLimit != null && currentLimit > 0)
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await provider.removeCategoryBudget(category);
                if (mounted) {
                  _showFeedback(lang.getText('category_budget_removed'));
                }
              },
              child: Text(
                lang.getText('remove_limit'),
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(lang.getText('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: catColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final text = catController.text.trim().replaceAll(',', '.');
              final val = double.tryParse(text) ?? 0;
              Navigator.of(ctx).pop();
              if (val > 0) {
                await provider.setCategoryBudget(category, val);
                if (mounted) {
                  _showFeedback('${lang.getText('category_budget_saved')} ($catName: ${AppConstants.defaultCurrency}${val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(2)})');
                }
              } else {
                await provider.removeCategoryBudget(category);
                if (mounted) {
                  _showFeedback(lang.getText('category_budget_removed'));
                }
              }
            },
            child: Text(lang.getText('save')),
          ),
        ],
      ),
    );
  }

  void _showFeedback(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    Timer? timer;
    timer = Timer(const Duration(seconds: 3), () {
      try {
        messenger.hideCurrentSnackBar();
      } catch (_) {}
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.success,
      ),
    ).closed.then((_) => timer?.cancel());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<ExpenseProvider>();
    final lang = context.watch<LanguageProvider>();

    final totalSpent = provider.selectedMonthTotal;
    final currentOverall = provider.currentMonthBudget;
    final hasOverall = currentOverall != null && currentOverall > 0;
    final overallBudget = currentOverall ?? 0.0;
    final categoryBudgets = provider.currentMonthCategoryBudgets;
    final totalAllocated = provider.currentMonthBudgetData.totalAllocatedCategoryBudget;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2024) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.getText('monthly_target'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(provider.selectedMonth),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Selector: Overall Budget vs Category Budgets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pie_chart_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(lang.getText('overall_budget')),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.category_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(lang.getText('category_budgets')),
                        if (categoryBudgets.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${categoryBudgets.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Overall Monthly Budget
                _buildOverallTab(
                  context,
                  provider,
                  lang,
                  theme,
                  isDark,
                  totalSpent,
                  hasOverall,
                  overallBudget,
                ),

                // TAB 2: Category-wise Budget Limits
                _buildCategoriesTab(
                  context,
                  provider,
                  lang,
                  theme,
                  isDark,
                  totalAllocated,
                  hasOverall,
                  overallBudget,
                  categoryBudgets,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Tab 1: Overall Monthly Budget
  Widget _buildOverallTab(
    BuildContext context,
    ExpenseProvider provider,
    LanguageProvider lang,
    ThemeData theme,
    bool isDark,
    double totalSpent,
    bool hasOverall,
    double overallBudget,
  ) {
    final ratio = hasOverall ? (totalSpent / overallBudget).clamp(0.0, 1.0) : 0.0;
    final isExceeded = hasOverall && totalSpent > overallBudget;
    final isWarning = hasOverall && !isExceeded && (totalSpent / overallBudget >= 0.80);
    final statusColor = isExceeded
        ? AppColors.error
        : (isWarning ? AppColors.warning : AppColors.success);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Status Overview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF272A30), const Color(0xFF1E2126)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFEDF2F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.getText('total_spending'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      hasOverall
                          ? (isExceeded
                              ? 'Exceeded'
                              : (isWarning ? 'Approaching Limit' : 'On Track'))
                          : lang.getText('no_limit'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(
                        symbol: AppConstants.defaultCurrency,
                        decimalDigits: totalSpent % 1 == 0 ? 0 : 2,
                      ).format(totalSpent),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isExceeded ? AppColors.error : null,
                      ),
                    ),
                    if (hasOverall)
                      Text(
                        'of ${NumberFormat.currency(symbol: AppConstants.defaultCurrency, decimalDigits: overallBudget % 1 == 0 ? 0 : 2).format(overallBudget)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
                if (hasOverall) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: isDark ? Colors.white12 : Colors.black12,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(ratio * 100).toStringAsFixed(0)}% used',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.grey.shade600),
                      ),
                      Text(
                        isExceeded
                            ? '+${NumberFormat.currency(symbol: AppConstants.defaultCurrency, decimalDigits: (totalSpent - overallBudget) % 1 == 0 ? 0 : 2).format(totalSpent - overallBudget)} over'
                            : '${NumberFormat.currency(symbol: AppConstants.defaultCurrency, decimalDigits: (overallBudget - totalSpent) % 1 == 0 ? 0 : 2).format(overallBudget - totalSpent)} left',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Input Section
          Text(
            lang.getText('set_spending_limit'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _overallController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '${AppConstants.defaultCurrency} ',
              hintText: 'e.g. 1500.00',
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _overallController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        setState(() {
                          _overallController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 12),

          // Quick Increment Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [50, 100, 250, 500, 1000].map((step) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text('+${AppConstants.defaultCurrency}$step'),
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onPressed: () {
                      final current = double.tryParse(_overallController.text.replaceAll(',', '.')) ?? 0;
                      final updated = current + step;
                      setState(() {
                        _overallController.text = updated % 1 == 0 ? updated.toStringAsFixed(0) : updated.toStringAsFixed(2);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              if (hasOverall) ...[
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            await provider.setMonthlyBudget(0);
                            setState(() {
                              _isSaving = false;
                              _overallController.clear();
                            });
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              _showFeedback(lang.getText('remove_limit'));
                            }
                          },
                    child: Text(lang.getText('remove_limit')),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final text = _overallController.text.trim().replaceAll(',', '.');
                          final val = double.tryParse(text) ?? 0;
                          setState(() => _isSaving = true);
                          await provider.setMonthlyBudget(val);
                          setState(() => _isSaving = false);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            _showFeedback(val > 0
                                ? 'Overall budget set to ${AppConstants.defaultCurrency}${val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(2)}'
                                : lang.getText('remove_limit'));
                          }
                        },
                  child: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(lang.getText('save'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build Tab 2: Category-wise Budget Limits
  Widget _buildCategoriesTab(
    BuildContext context,
    ExpenseProvider provider,
    LanguageProvider lang,
    ThemeData theme,
    bool isDark,
    double totalAllocated,
    bool hasOverall,
    double overallBudget,
    Map<String, double> categoryBudgets,
  ) {
    return Column(
      children: [
        // Allocation Summary Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('total_category_budget'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      NumberFormat.currency(
                        symbol: AppConstants.defaultCurrency,
                        decimalDigits: totalAllocated % 1 == 0 ? 0 : 2,
                      ).format(totalAllocated),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${categoryBudgets.length} of ${AppConstants.categories.length} set',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // List of all categories
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: AppConstants.categories.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = AppConstants.categories[index];
              final catColor = AppConstants.getCategoryColor(category);
              final catIcon = AppConstants.getCategoryIcon(category);
              final catName = lang.getCategory(category);
              final catSpent = provider.monthCategoryBreakdown[category] ?? 0.0;
              final catBudget = categoryBudgets[category];
              final hasBudget = catBudget != null && catBudget > 0;

              final ratio = hasBudget ? (catSpent / catBudget).clamp(0.0, 1.0) : 0.0;
              final isOver = hasBudget && catSpent > catBudget;
              final isWarn = hasBudget && !isOver && (catSpent / catBudget >= 0.80);
              final pillColor = isOver
                  ? AppColors.error
                  : (isWarn ? AppColors.warning : AppColors.success);

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF26292E) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: hasBudget
                        ? pillColor.withValues(alpha: isDark ? 0.35 : 0.25)
                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    width: hasBudget ? 1.2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showCategoryLimitDialog(context, category, provider, lang),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Category Icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(catIcon, color: catColor, size: 20),
                              ),
                              const SizedBox(width: 12),

                              // Name & Spent
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      catName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${NumberFormat.currency(symbol: AppConstants.defaultCurrency, decimalDigits: catSpent % 1 == 0 ? 0 : 2).format(catSpent)} spent',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Right: Limit Status or "+ Set" button
                              if (hasBudget) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      NumberFormat.currency(
                                        symbol: AppConstants.defaultCurrency,
                                        decimalDigits: catBudget % 1 == 0 ? 0 : 2,
                                      ).format(catBudget),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: pillColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isOver
                                            ? 'Exceeded'
                                            : '${(ratio * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: pillColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.shade400),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_rounded, size: 14, color: theme.colorScheme.primary),
                                      const SizedBox(width: 2),
                                      Text(
                                        lang.getText('set_category_limit'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Mini Progress Bar if limit is set
                          if (hasBudget) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio,
                                backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                                valueColor: AlwaysStoppedAnimation(pillColor),
                                minHeight: 5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
