import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../state/auth_provider.dart';
import '../state/expense_provider.dart';
import '../widgets/calendar_selector_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/theme_settings_sheet.dart';
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

  void _confirmSignOut(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userEmail = authProvider.user?.email ?? 'your account';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: Text('Are you sure you want to sign out from $userEmail?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ExpenseProvider>().clearData();
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
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
            tooltip: _isSearching ? 'Close Search' : 'Search',
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
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Filter by Month / Date',
            onPressed: () {
              CalendarSelectorSheet.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Theme & Colors',
            onPressed: () {
              ThemeSettingsSheet.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            final user = auth.user;
                            final name = (user?.displayName != null && user!.displayName!.isNotEmpty)
                                ? user.displayName
                                : (user?.email?.split('@').first ?? 'User');
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12, left: 4),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                    child: Text(
                                      (name != null && name.isNotEmpty ? name[0] : 'U').toUpperCase(),
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello, $name 👋',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          user?.email ?? '',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Dynamic Spending Card with Calendar Selector
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                isDark
                                    ? theme.colorScheme.primaryContainer
                                    : Color.lerp(theme.colorScheme.primary, Colors.black, 0.25)!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Bar: Period Label and Quick Nav + Calendar Trigger
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        provider.selectedDate != null
                                            ? 'Daily Spending'
                                            : (provider.isCurrentMonth
                                                ? "This Month's Spending"
                                                : "Selected Month"),
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Month / Date Chip with interactive tap to open Calendar
                                  InkWell(
                                    onTap: () => CalendarSelectorSheet.show(context),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.22),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.calendar_month_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            provider.selectedDate != null
                                                ? DateFormat('MMM dd, yyyy')
                                                    .format(provider.selectedDate!)
                                                : DateFormat('MMM yyyy')
                                                    .format(provider.selectedMonth),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons.arrow_drop_down_rounded,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Total Amount Display
                              Text(
                                NumberFormat.currency(
                                  symbol: AppConstants.defaultCurrency,
                                  decimalDigits: 2,
                                ).format(
                                  provider.selectedDate != null
                                      ? provider.selectedDateTotal
                                      : provider.selectedMonthTotal,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Bottom Controls: Quick Previous/Next Month & Active Date Filter Chip
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Quick Month Nav Arrows
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => provider.previousMonth(),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.chevron_left_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => provider.nextMonth(),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${expenses.length} in period',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.85),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // If a specific day filter is active, show button to revert back to whole month
                                  if (provider.selectedDate != null)
                                    InkWell(
                                      onTap: () => provider.clearDateFilter(),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.close_rounded,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'All Month',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else if (!provider.isCurrentMonth)
                                    InkWell(
                                      onTap: () => provider.resetToCurrentMonth(),
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Back to Current',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transactions',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            if (provider.selectedDate != null || !provider.isCurrentMonth || provider.selectedCategory != 'All')
                              Text(
                                [
                                  if (provider.selectedDate != null)
                                    DateFormat('MMM dd').format(provider.selectedDate!)
                                  else if (!provider.isCurrentMonth)
                                    DateFormat('MMM yyyy').format(provider.selectedMonth),
                                  if (provider.selectedCategory != 'All')
                                    provider.selectedCategory,
                                ].join(' • '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        if (provider.selectedCategory != 'All' || provider.selectedDate != null || !provider.isCurrentMonth)
                          TextButton(
                            onPressed: () {
                              provider.setSelectedCategory('All');
                              provider.resetToCurrentMonth();
                            },
                            child: const Text('Reset Filters'),
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
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
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
        selectedColor: theme.colorScheme.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLow,
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
