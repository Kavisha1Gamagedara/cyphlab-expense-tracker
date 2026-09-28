import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../state/expense_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/expense_tile.dart';
import 'expense_form.dart';

/// Dashboard screen displaying monthly totals, category filters, and expense history.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start listening to the Firestore stream upon entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openExpenseForm([dynamic expenseToEdit]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseForm(expenseToEdit: expenseToEdit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                onChanged: (val) {
                  context.read<ExpenseProvider>().setSearchQuery(val);
                },
              )
            : const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<ExpenseProvider>().setSearchQuery('');
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final monthlyTotal = NumberFormat.currency(
            symbol: AppConstants.defaultCurrency,
            decimalDigits: 2,
          ).format(provider.currentMonthTotal);

          final expenses = provider.filteredExpenses;

          return RefreshIndicator(
            onRefresh: () async {
              provider.startListening();
            },
            child: CustomScrollView(
              slivers: [
                // Top Summary Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'This Month\'s Spending',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  DateFormat('MMMM yyyy').format(DateTime.now()),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            monthlyTotal,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_rounded,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${provider.allExpenses.length} Total Records',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Category Filter Bar
                SliverToBoxAdapter(
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _buildCategoryChip('All', provider),
                        ...AppConstants.categories.map(
                          (cat) => _buildCategoryChip(cat, provider),
                        ),
                      ],
                    ),
                  ),
                ),

                // Header for Recent Transactions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        if (provider.selectedCategory != 'All')
                          TextButton(
                            onPressed: () {
                              provider.setSelectedCategory('All');
                            },
                            child: const Text('Clear Filter'),
                          ),
                      ],
                    ),
                  ),
                ),

                // Content Area: Loading, Error, Empty, or List
                if (provider.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (provider.errorMessage != null && provider.allExpenses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorState(
                      message: provider.errorMessage,
                      onRetry: () => provider.startListening(),
                    ),
                  )
                else if (expenses.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      onAction: () => _openExpenseForm(),
                      actionLabel: 'Add Expense',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final expense = expenses[index];
                          return ExpenseTile(
                            expense: expense,
                            onTap: () => _openExpenseForm(expense),
                            onDelete: () => provider.deleteExpense(expense.id),
                          );
                        },
                        childCount: expenses.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openExpenseForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildCategoryChip(String category, ExpenseProvider provider) {
    final isSelected = provider.selectedCategory == category;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(category),
        onSelected: (_) => provider.setSelectedCategory(category),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : (isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
