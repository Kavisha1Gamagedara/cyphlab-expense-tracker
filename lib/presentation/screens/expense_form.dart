import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../data/models/expense_model.dart';
import '../state/currency_provider.dart';
import '../state/expense_provider.dart';
import '../state/language_provider.dart';
import '../state/notification_provider.dart';

/// Form screen / bottom sheet to Add or Edit an Expense with full validation.
class ExpenseForm extends StatefulWidget {
  final Expense? expenseToEdit;

  const ExpenseForm({super.key, this.expenseToEdit});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isSubmitting = false;

  bool get _isEditing => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expenseToEdit;
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: expense?.notes ?? '');
    _selectedCategory = expense?.category ?? AppConstants.categories.first;
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();

    setState(() => _isSubmitting = true);

    final provider = context.read<ExpenseProvider>();
    bool success;

    if (_isEditing) {
      final updatedExpense = widget.expenseToEdit!.copyWith(
        title: title,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        notes: notes.isNotEmpty ? notes : null,
      );
      success = await provider.updateExpense(updatedExpense);
    } else {
      final newExpense = Expense(
        title: title,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        notes: notes.isNotEmpty ? notes : null,
      );
      success = await provider.addExpense(newExpense);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        // Trigger Budget Warning Notification if thresholds crossed (80% or 100%)
        try {
          final notif = context.read<NotificationProvider>();
          final lang = context.read<LanguageProvider>();
          final currency = context.read<CurrencyProvider>().symbol;

          // 1. Check Category Limit
          final catBudget = provider.getCategoryBudget(_selectedCategory);
          if (catBudget != null && catBudget > 0) {
            final catSpent = provider.categoryTotal(_selectedCategory);
            if (catSpent >= catBudget) {
              notif.sendBudgetAlert(
                title: lang.getText('budget_exceeded_title'),
                body: '$_selectedCategory ${lang.getText('budget_exceeded_category_body')} ($currency${catSpent.toStringAsFixed(2)} / $currency${catBudget.toStringAsFixed(2)})',
              );
            } else if (catSpent >= catBudget * 0.8) {
              notif.sendBudgetAlert(
                title: lang.getText('budget_warning_80_title'),
                body: '$_selectedCategory ${lang.getText('budget_warning_category_body')} ($currency${catSpent.toStringAsFixed(2)} / $currency${catBudget.toStringAsFixed(2)})',
              );
            }
          }

          // 2. Check Overall Monthly Limit
          final overallBudget = provider.currentMonthBudget;
          if (overallBudget != null && overallBudget > 0) {
            final totalSpent = provider.selectedMonthTotal;
            if (totalSpent >= overallBudget) {
              notif.sendBudgetAlert(
                title: lang.getText('budget_exceeded_title'),
                body: '${lang.getText('budget_exceeded_overall_body')} ($currency${totalSpent.toStringAsFixed(2)} / $currency${overallBudget.toStringAsFixed(2)})',
              );
            } else if (totalSpent >= overallBudget * 0.8) {
              notif.sendBudgetAlert(
                title: lang.getText('budget_warning_80_title'),
                body: '${lang.getText('budget_warning_overall_body')} ($currency${totalSpent.toStringAsFixed(2)} / $currency${overallBudget.toStringAsFixed(2)})',
              );
            }
          }
        } catch (e) {
          debugPrint('[ExpenseForm] Budget notification error: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Expense updated' : 'Expense saved'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Operation failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final provider = context.read<ExpenseProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Expense'),
          ],
        ),
        content: const Text(
          'Move this expense to the Recycle Bin? It will be kept safely for 5 days before being permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Move to Bin'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isSubmitting = true);
      final success = await provider.deleteExpense(widget.expenseToEdit!.id);
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          try {
            final notif = context.read<NotificationProvider>();
            final lang = context.read<LanguageProvider>();
            notif.sendRecycleBinWarning(
              title: lang.getText('recycle_bin_warning_title'),
              body: '1 ${lang.getText('recycle_bin_warning_body')}',
            );
          } catch (e) {
            debugPrint('[ExpenseForm] Recycle bin alert error: $e');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense moved to Recycle Bin (kept for 5 days)'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to delete expense'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: 'Delete Expense',
              onPressed: _isSubmitting ? null : _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Input Field (Hero element)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHigh
                        : theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? theme.colorScheme.outlineVariant.withValues(alpha: 0.2)
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              AppConstants.defaultCurrency,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: '0.00',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid amount greater than zero';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Title Input Field
                Text(
                  'Title',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Grocery Shopping, Gas, Rent',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Category Selector
                Text(
                  'Category',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final catColor = AppConstants.getCategoryColor(cat);
                    final catIcon = AppConstants.getCategoryIcon(cat);

                    return ChoiceChip(
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat);
                        }
                      },
                      avatar: Icon(
                        catIcon,
                        size: 16,
                        color: isSelected ? Colors.white : catColor,
                      ),
                      label: Text(cat),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      selectedColor: catColor,
                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Date Picker
                Text(
                  'Date',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(_selectedDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Notes / Description Field
                Text(
                  'Notes (Optional)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add extra details or reminders...',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 3,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Expense' : 'Save Expense',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
