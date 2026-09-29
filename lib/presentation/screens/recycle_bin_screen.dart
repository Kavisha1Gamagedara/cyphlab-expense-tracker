import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../data/models/expense_model.dart';
import '../state/expense_provider.dart';

/// Screen allowing users to view, restore, or permanently delete items in the Recycle Bin.
/// Items in the recycle bin are kept for 5 days before automatic cleanup.
class RecycleBinScreen extends StatelessWidget {
  const RecycleBinScreen({super.key});

  void _confirmEmptyBin(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Empty Recycle Bin'),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete all items in the Recycle Bin? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await provider.emptyRecycleBin();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Recycle Bin emptied successfully'
                          : 'Failed to empty Recycle Bin',
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Empty All'),
          ),
        ],
      ),
    );
  }

  void _confirmPermanentDelete(BuildContext context, Expense expense) {
    final provider = context.read<ExpenseProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Forever'),
          ],
        ),
        content: Text(
          'Permanently delete "${expense.title}"? You will not be able to restore this record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success =
                  await provider.permanentlyDeleteExpense(expense.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Item permanently deleted'
                          : 'Failed to delete item',
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final recycled = provider.recycledExpenses;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Recycle Bin'),
            actions: [
              if (recycled.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded),
                  tooltip: 'Empty Bin',
                  onPressed: () => _confirmEmptyBin(context),
                ),
            ],
          ),
          body: Column(
            children: [
              // 5-day retention notice banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '5-Day Temporary Retention',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Deleted expenses are retained for 5 days before permanent removal. You can restore them anytime.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // List or Empty State
              Expanded(
                child: recycled.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.grey.shade100,
                                ),
                                child: Icon(
                                  Icons.auto_delete_outlined,
                                  size: 42,
                                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Recycle Bin is Empty',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'No deleted expenses. Items deleted in the last 5 days will appear here.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: recycled.length,
                        itemBuilder: (context, index) {
                          final expense = recycled[index];
                          return _RecycledExpenseTile(
                            expense: expense,
                            onRestore: () async {
                              final success =
                                  await provider.restoreExpense(expense.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Restored "${expense.title}"'
                                          : 'Failed to restore expense',
                                    ),
                                    backgroundColor: success
                                        ? AppColors.success
                                        : AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            onPermanentDelete: () =>
                                _confirmPermanentDelete(context, expense),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecycledExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;

  const _RecycledExpenseTile({
    required this.expense,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = AppConstants.getCategoryColor(expense.category);
    final categoryIcon = AppConstants.getCategoryIcon(expense.category);

    // Days left calculation
    String daysLeftText = '';
    Color daysLeftColor = AppColors.warning;
    if (expense.deletedAt != null) {
      final expiryDate = expense.deletedAt!.add(const Duration(days: 5));
      final remaining = expiryDate.difference(DateTime.now());
      if (remaining.isNegative) {
        daysLeftText = 'Expiring soon';
        daysLeftColor = AppColors.error;
      } else if (remaining.inDays >= 1) {
        daysLeftText = '${remaining.inDays + 1} days left';
        daysLeftColor = remaining.inDays <= 1 ? AppColors.error : AppColors.warning;
      } else {
        daysLeftText = '${remaining.inHours}h left';
        daysLeftColor = AppColors.error;
      }
    } else {
      daysLeftText = '5 days left';
    }

    final formattedAmount = NumberFormat.currency(
      symbol: AppConstants.defaultCurrency,
      decimalDigits: 2,
    ).format(expense.amount);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoryIcon,
                color: categoryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          expense.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: daysLeftColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          daysLeftText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: daysLeftColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        formattedAmount,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  ${DateFormat('MMM dd').format(expense.date)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Action Buttons: Restore & Permanent Delete
            IconButton(
              icon: const Icon(Icons.restore_from_trash_rounded),
              color: AppColors.success,
              tooltip: 'Restore Expense',
              onPressed: onRestore,
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded),
              color: AppColors.error,
              tooltip: 'Permanently Delete',
              onPressed: onPermanentDelete,
            ),
          ],
        ),
      ),
    );
  }
}
