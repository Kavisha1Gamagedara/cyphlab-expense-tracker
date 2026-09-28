import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../state/expense_provider.dart';
import '../widgets/calendar_selector_sheet.dart';
import '../widgets/export_report_sheet.dart';
import '../widgets/monthly_analytics_card.dart';
import '../widgets/monthly_budget_card.dart';
import '../widgets/theme_settings_sheet.dart';
import 'recycle_bin_screen.dart';

/// Dedicated Analytics Dashboard screen showing in-depth monthly/daily spending insights.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final periodTitle = provider.selectedDate != null
            ? DateFormat('MMMM dd, yyyy').format(provider.selectedDate!)
            : DateFormat('MMMM yyyy').format(provider.selectedMonth);

        final totalSpent = provider.selectedDate != null
            ? provider.selectedDateTotal
            : provider.selectedMonthTotal;

        final breakdown = provider.monthCategoryBreakdown;
        final totalCount = provider.filteredExpenses.length;

        // Find top category
        String topCategoryName = 'None';
        double topCategoryAmount = 0.0;
        if (breakdown.isNotEmpty) {
          final sorted = breakdown.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          topCategoryName = sorted.first.key;
          topCategoryAmount = sorted.first.value;
        }

        // Daily average for the month (if month mode)
        final daysInMonth = DateTime(
          provider.selectedMonth.year,
          provider.selectedMonth.month + 1,
          0,
        ).day;
        final dailyAverage = totalSpent / (provider.selectedDate != null ? 1 : daysInMonth);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Analytics'),
            actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              tooltip: 'Select Period',
              onPressed: () => CalendarSelectorSheet.show(context),
            ),
              Consumer<ExpenseProvider>(
                builder: (context, provider, _) {
                  final count = provider.recycledCount;
                  return PopupMenuButton<String>(
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      backgroundColor: AppColors.error,
                      child: const Icon(Icons.more_vert_rounded),
                    ),
                    tooltip: 'More Options',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'export':
                          ExportReportSheet.show(
                            context,
                            expenses: provider.filteredExpenses,
                            periodTitle: periodTitle,
                            totalAmount: totalSpent,
                          );
                          break;
                        case 'recycle_bin':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RecycleBinScreen(),
                            ),
                          );
                          break;
                        case 'theme':
                          ThemeSettingsSheet.show(context);
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.file_download_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Export Report (PDF/CSV)'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'recycle_bin',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: const Text('Recycle Bin')),
                            if (count > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'theme',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.palette_outlined,
                                size: 18,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Theme & Colors'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              provider.startListening();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                                onPressed: () => provider.previousMonth(),
                                tooltip: 'Previous Month',
                                visualDensity: VisualDensity.compact,
                              ),
                              InkWell(
                                onTap: () => CalendarSelectorSheet.show(context),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        periodTitle,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down_rounded, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                                onPressed: () => provider.nextMonth(),
                                tooltip: 'Next Month',
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          if (!provider.isCurrentMonth || provider.selectedDate != null)
                            TextButton(
                              onPressed: () => provider.resetToCurrentMonth(),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text('Current'),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Quick Statistics Cards (Total, Top Category, Daily Avg, Transactions)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        // Total Spending Card
                        Expanded(
                          child: _buildMetricCard(
                            theme: theme,
                            isDark: isDark,
                            label: 'Total Spending',
                            value: NumberFormat.currency(
                              symbol: AppConstants.defaultCurrency,
                              decimalDigits: 2,
                            ).format(totalSpent),
                            icon: Icons.account_balance_wallet_rounded,
                            iconColor: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Top Category Card
                        Expanded(
                          child: _buildMetricCard(
                            theme: theme,
                            isDark: isDark,
                            label: 'Top Category',
                            value: topCategoryName,
                            subValue: topCategoryAmount > 0
                                ? NumberFormat.currency(
                                    symbol: AppConstants.defaultCurrency,
                                    decimalDigits: 0,
                                  ).format(topCategoryAmount)
                                : null,
                            icon: topCategoryAmount > 0
                                ? AppConstants.getCategoryIcon(topCategoryName)
                                : Icons.category_rounded,
                            iconColor: topCategoryAmount > 0
                                ? AppConstants.getCategoryColor(topCategoryName)
                                : theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        // Daily Average Card
                        Expanded(
                          child: _buildMetricCard(
                            theme: theme,
                            isDark: isDark,
                            label: provider.selectedDate != null ? 'Daily Total' : 'Daily Average',
                            value: NumberFormat.currency(
                              symbol: AppConstants.defaultCurrency,
                              decimalDigits: 2,
                            ).format(dailyAverage),
                            icon: Icons.show_chart_rounded,
                            iconColor: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Transactions Count Card
                        Expanded(
                          child: _buildMetricCard(
                            theme: theme,
                            isDark: isDark,
                            label: 'Transactions',
                            value: '$totalCount',
                            subValue: 'records',
                            icon: Icons.receipt_long_rounded,
                            iconColor: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Monthly Budgeting / Limit Card with Line Chart Progression
                  MonthlyBudgetCard(
                    spentAmount: totalSpent,
                    budgetAmount: provider.currentMonthBudget,
                    periodTitle: periodTitle,
                    cumulativeSpending: provider.cumulativeExpensesInSelectedMonth,
                    totalDays: provider.daysInSelectedMonth,
                    onSetBudget: () => _showSetBudgetDialog(context, provider),
                  ),

                  // Main Monthly Analytics Card (Interactive Pie & Bar Charts)
                  MonthlyAnalyticsCard(
                    categoryBreakdown: breakdown,
                    totalAmount: totalSpent,
                    periodTitle: periodTitle,
                  ),

                  // Export Summary Action Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.surfaceDark,
                                  AppColors.primaryDark.withValues(alpha: 0.4),
                                ]
                              : [
                                  Colors.white,
                                  AppColors.primary.withValues(alpha: 0.05),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.print_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Export Expense Report',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Generate printable PDF or Excel CSV for $periodTitle',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () {
                              ExportReportSheet.show(
                                context,
                                expenses: provider.filteredExpenses,
                                periodTitle: periodTitle,
                                totalAmount: totalSpent,
                              );
                            },
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: const Text('Export'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSetBudgetDialog(BuildContext context, ExpenseProvider provider) {
    final currentBudget = provider.currentMonthBudget;
    final controller = TextEditingController(
      text: currentBudget != null && currentBudget > 0 ? currentBudget.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.savings_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Monthly Budget Target'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set a spending limit for ${DateFormat('MMMM yyyy').format(provider.selectedMonth)}. We\'ll warn you as you approach it.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Budget Amount',
                prefixText: '${AppConstants.defaultCurrency} ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                hintText: 'e.g. 500',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              final parsed = double.tryParse(text);
              if (parsed != null && parsed >= 0) {
                Navigator.of(ctx).pop();
                await provider.setMonthlyBudget(parsed);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        parsed > 0
                            ? 'Budget target of ${AppConstants.defaultCurrency}${parsed.toStringAsFixed(0)} saved!'
                            : 'Budget limit cleared.',
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Limit'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required bool isDark,
    required String label,
    required String value,
    String? subValue,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
