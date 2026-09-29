import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../data/models/expense_model.dart';
import '../state/auth_provider.dart';
import '../state/expense_provider.dart';
import '../state/language_provider.dart';
import '../widgets/calendar_selector_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/export_report_sheet.dart';
import '../widgets/theme_settings_sheet.dart';
import 'expense_form.dart';
import 'onboarding_screen.dart';
import 'recycle_bin_screen.dart';
import 'settings_screen.dart';

/// Dashboard screen displaying monthly totals, calendar strip, bento metrics, and expense history.
/// Styled with a creative, modern, and playful aesthetic inspired by modern mobile UI concepts.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  late DateTime _weekReferenceDate;

  @override
  void initState() {
    super.initState();
    _weekReferenceDate = DateTime.now();
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

  void _openExpenseForm([Expense? expenseToEdit]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseForm(expenseToEdit: expenseToEdit),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final lang = context.read<LanguageProvider>();
    final userEmail = authProvider.user?.email ?? 'your account';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(lang.getText('sign_out')),
        content: Text('${lang.getText('sign_out_confirm')}\n($userEmail)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(lang.getText('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ExpenseProvider>().clearData();
              context.read<AuthProvider>().signOut();
            },
            child: Text(lang.getText('sign_out')),
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, ExpenseProvider provider) {
    final currentBudget = provider.currentMonthBudget;
    final lang = context.read<LanguageProvider>();
    final controller = TextEditingController(
      text: currentBudget != null && currentBudget > 0
          ? currentBudget.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.savings_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(lang.getText('monthly_target')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('MMMM yyyy').format(provider.selectedMonth)} ${lang.getText('set_spending_limit')}:',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '${AppConstants.defaultCurrency} ',
                hintText: 'e.g. 1500',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (currentBudget != null && currentBudget > 0)
            TextButton(
              onPressed: () async {
                await provider.setMonthlyBudget(0);
                if (ctx.mounted) Navigator.of(ctx).pop();
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
            onPressed: () async {
              final val = double.tryParse(controller.text.trim()) ?? 0;
              await provider.setMonthlyBudget(val);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(lang.getText('save')),
          ),
        ],
      ),
    );
  }

  /// Get the 7 days of the week starting Sunday
  List<DateTime> _getWeekDays(DateTime refDate) {
    final startOfWeek = refDate.subtract(Duration(days: refDate.weekday % 7));
    return List.generate(
      7,
      (i) => DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Consumer<ExpenseProvider>(
          builder: (context, provider, child) {
            final expenses = provider.filteredExpenses;
            final user = context.watch<AuthProvider>().user;
            final name =
                (user?.displayName != null && user!.displayName!.isNotEmpty)
                ? user.displayName
                : (user?.email?.split('@').first ?? 'Friend');

            final totalSpent = provider.selectedDate != null
                ? provider.selectedDateTotal
                : provider.selectedMonthTotal;

            final double? rawBudget = provider.currentMonthBudget;
            final bool hasBudget = rawBudget != null && rawBudget > 0;
            final double budget = rawBudget ?? 0.0;
            final double budgetRemaining = budget - totalSpent;

            // Daily average calculation
            final daysInMonth = provider.daysInSelectedMonth;
            final dailyAverage =
                totalSpent / (provider.selectedDate != null ? 1 : daysInMonth);

            // Find top category
            final breakdown = provider.monthCategoryBreakdown;
            String topCategoryName = 'None';
            if (breakdown.isNotEmpty) {
              final sorted = breakdown.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              topCategoryName = sorted.first.key;
            }

            final periodTitle = provider.selectedDate != null
                ? DateFormat('MMMM dd, yyyy').format(provider.selectedDate!)
                : DateFormat('MMMM yyyy').format(provider.selectedMonth);

            // Keep _weekReferenceDate synchronized with selected date or month
            if (provider.selectedDate != null) {
              _weekReferenceDate = provider.selectedDate!;
            } else if (_weekReferenceDate.year != provider.selectedMonth.year ||
                _weekReferenceDate.month != provider.selectedMonth.month) {
              final now = DateTime.now();
              if (now.year == provider.selectedMonth.year &&
                  now.month == provider.selectedMonth.month) {
                _weekReferenceDate = now;
              } else {
                _weekReferenceDate = DateTime(
                  provider.selectedMonth.year,
                  provider.selectedMonth.month,
                  1,
                );
              }
            }

            final weekDays = _getWeekDays(_weekReferenceDate);

            return RefreshIndicator(
              onRefresh: () async {
                provider.startListening();
              },
              child: CustomScrollView(
                slivers: [
                  // 1. Creative Profile Header & Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Avatar + Greeting + Badge
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withValues(
                                        alpha: 0.6,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    (name != null && name.isNotEmpty
                                            ? name[0]
                                            : 'U')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${lang.getText('hello')}, $name 👋',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          letterSpacing: -0.3,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.primary.withValues(
                                              alpha: 0.2,
                                            )
                                          : AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.bolt_rounded,
                                          size: 12,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          lang.getText('smart_saver'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Right: Options Menu with Notification Badge
                          Consumer<ExpenseProvider>(
                            builder: (context, provider, _) {
                              final count = provider.recycledCount;
                              return Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.black.withValues(alpha: 0.08),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.25 : 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: PopupMenuButton<String>(
                                  icon: Badge(
                                    isLabelVisible: count > 0,
                                    label: Text('$count'),
                                    backgroundColor: AppColors.error,
                                    child: Icon(
                                      Icons.more_vert_rounded,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimaryLight,
                                      size: 22,
                                    ),
                                  ),
                                  tooltip: lang.getText('settings'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'settings':
                                        SettingsScreen.show(context);
                                        break;
                                      case 'calendar':
                                        CalendarSelectorSheet.show(context);
                                        break;
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
                                            builder: (_) =>
                                                const RecycleBinScreen(),
                                          ),
                                        );
                                        break;
                                      case 'theme':
                                        ThemeSettingsSheet.show(context);
                                        break;
                                      case 'onboarding':
                                        OnboardingScreen.show(context);
                                        break;
                                      case 'sign_out':
                                        _confirmSignOut(context);
                                        break;
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(
                                      value: 'settings',
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.settings_outlined,
                                              size: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            lang.getText('settings'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'calendar',
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.calendar_month_rounded,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            lang.getText('select_month_day'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'export',
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.file_download_outlined,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(lang.getText('export_report')),
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
                                              color: AppColors.warning
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: AppColors.warning,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              lang.getText('recycle_bin'),
                                            ),
                                          ),
                                          if (count > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.error,
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                              color: AppColors.accent
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.palette_outlined,
                                              size: 18,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(lang.getText('theme_colors')),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'onboarding',
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFC084FC,
                                              ).withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.auto_awesome_rounded,
                                              size: 18,
                                              color: Color(0xFFA855F7),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            lang.getText('onboarding_story'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    PopupMenuItem(
                                      value: 'sign_out',
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.error.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.logout_rounded,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            lang.getText('sign_out'),
                                            style: const TextStyle(
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Sleek Stadium Search Field
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.03,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            hintText: lang.getText('search_hint'),
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.setSearchQuery('');
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          onChanged: (val) {
                            provider.setSearchQuery(val);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),

                  // 3. Horizontal Interactive Calendar Strip (Inspired by Dribbble concept)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.03,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Month Header with Chevrons and All Month button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () =>
                                      CalendarSelectorSheet.show(context),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          DateFormat(
                                            'MMMM yyyy',
                                          ).format(provider.selectedMonth),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (provider.selectedDate != null)
                                      InkWell(
                                        onTap: () => provider.clearDateFilter(),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            lang.getText('all_month'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.chevron_left_rounded,
                                        size: 22,
                                      ),
                                      tooltip: 'Previous week',
                                      onPressed: () {
                                        setState(() {
                                          _weekReferenceDate =
                                              _weekReferenceDate.subtract(
                                                const Duration(days: 7),
                                              );
                                          if (_weekReferenceDate.month !=
                                                  provider
                                                      .selectedMonth
                                                      .month ||
                                              _weekReferenceDate.year !=
                                                  provider.selectedMonth.year) {
                                            provider.setSelectedMonth(
                                              DateTime(
                                                _weekReferenceDate.year,
                                                _weekReferenceDate.month,
                                              ),
                                            );
                                          }
                                        });
                                      },
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 22,
                                      ),
                                      tooltip: 'Next week',
                                      onPressed: () {
                                        setState(() {
                                          _weekReferenceDate =
                                              _weekReferenceDate.add(
                                                const Duration(days: 7),
                                              );
                                          if (_weekReferenceDate.month !=
                                                  provider
                                                      .selectedMonth
                                                      .month ||
                                              _weekReferenceDate.year !=
                                                  provider.selectedMonth.year) {
                                            provider.setSelectedMonth(
                                              DateTime(
                                                _weekReferenceDate.year,
                                                _weekReferenceDate.month,
                                              ),
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // 7-Day Horizontal Strip
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: weekDays.map((dayDate) {
                                final isSelected =
                                    provider.selectedDate != null &&
                                    provider.selectedDate!.year ==
                                        dayDate.year &&
                                    provider.selectedDate!.month ==
                                        dayDate.month &&
                                    provider.selectedDate!.day == dayDate.day;

                                final isToday =
                                    dayDate.year == DateTime.now().year &&
                                    dayDate.month == DateTime.now().month &&
                                    dayDate.day == DateTime.now().day;

                                final hasExpenses =
                                    (provider
                                            .dailyExpensesInSelectedMonth[dayDate
                                            .day] ??
                                        0) >
                                    0;
                                final isDifferentMonth =
                                    dayDate.month !=
                                    provider.selectedMonth.month;

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isSelected) {
                                        provider.clearDateFilter();
                                      } else {
                                        provider.setSelectedDate(dayDate);
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark
                                                  ? Colors.white
                                                  : const Color(0xFF18181B))
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: isToday && !isSelected
                                            ? Border.all(
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.5),
                                                width: 1.5,
                                              )
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            DateFormat('E').format(
                                              dayDate,
                                            )[0], // S, M, T, W, T, F, S
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? (isDark
                                                        ? Colors.black87
                                                        : Colors.white)
                                                  : (isDifferentMonth
                                                        ? Colors.grey.shade400
                                                        : (isDark
                                                              ? Colors.white54
                                                              : Colors
                                                                    .grey
                                                                    .shade600)),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${dayDate.day}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? (isDark
                                                        ? Colors.black
                                                        : Colors.white)
                                                  : (isDifferentMonth
                                                        ? Colors.grey.shade400
                                                        : (isDark
                                                              ? Colors.white
                                                              : AppColors
                                                                    .textPrimaryLight)),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Micro dot indicator for days with expenses
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected
                                                  ? (isDark
                                                        ? theme
                                                              .colorScheme
                                                              .primary
                                                        : Colors.amberAccent)
                                                  : (hasExpenses
                                                        ? theme
                                                              .colorScheme
                                                              .primary
                                                        : Colors.transparent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. Hero Spending & Budget Progress Card (High-Contrast Dribbble Style)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF1E293B),
                                    const Color(0xFF0F172A),
                                  ]
                                : [
                                    const Color(
                                      0xFF18181B,
                                    ), // Sleek pitch dark card
                                    const Color(0xFF27272A),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Period Label & Status Pill
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  provider.selectedDate != null
                                      ? lang.getText('daily_spending')
                                      : (provider.isCurrentMonth
                                            ? lang.getText(
                                                'this_month_spending',
                                              )
                                            : lang.getText('selected_month')),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                // Status Pill
                                InkWell(
                                  onTap: () =>
                                      _showSetBudgetDialog(context, provider),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hasBudget
                                          ? (totalSpent > budget
                                                ? AppColors.error.withValues(
                                                    alpha: 0.25,
                                                  )
                                                : (totalSpent / budget >= 0.8
                                                      ? AppColors.warning
                                                            .withValues(
                                                              alpha: 0.25,
                                                            )
                                                      : AppColors.success
                                                            .withValues(
                                                              alpha: 0.25,
                                                            )))
                                          : Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: hasBudget
                                            ? (totalSpent > budget
                                                  ? AppColors.error
                                                  : (totalSpent / budget >= 0.8
                                                        ? AppColors.warning
                                                        : AppColors.success))
                                            : Colors.white24,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          hasBudget
                                              ? Icons.shield_rounded
                                              : Icons
                                                    .add_circle_outline_rounded,
                                          size: 13,
                                          color: hasBudget
                                              ? (totalSpent > budget
                                                    ? Colors.redAccent.shade100
                                                    : (totalSpent / budget >=
                                                              0.8
                                                          ? Colors.amberAccent
                                                          : Colors.greenAccent))
                                              : Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          hasBudget
                                              ? (totalSpent > budget
                                                    ? lang.getText('exceeded')
                                                    : (totalSpent / budget >=
                                                              0.8
                                                          ? lang.getText(
                                                              'limit_warning',
                                                            )
                                                          : lang.getText(
                                                              'on_track',
                                                            )))
                                              : lang.getText('set_target'),
                                          style: TextStyle(
                                            color: hasBudget
                                                ? (totalSpent > budget
                                                      ? Colors
                                                            .redAccent
                                                            .shade100
                                                      : (totalSpent / budget >=
                                                                0.8
                                                            ? Colors.amberAccent
                                                            : Colors
                                                                  .greenAccent))
                                                : Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Total Amount
                            Text(
                              NumberFormat.currency(
                                symbol: AppConstants.defaultCurrency,
                                decimalDigits: 2,
                              ).format(totalSpent),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),

                            // Budget Progress Indicator (if budget set)
                            if (hasBudget) ...[
                              const SizedBox(height: 14),
                              Builder(
                                builder: (context) {
                                  final ratio = (totalSpent / budget).clamp(
                                    0.0,
                                    1.0,
                                  );
                                  final isOver = totalSpent > budget;
                                  final isWarn =
                                      !isOver && (totalSpent / budget) >= 0.8;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 6,
                                              width: double.infinity,
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                            ),
                                            FractionallySizedBox(
                                              widthFactor: ratio,
                                              child: Container(
                                                height: 6,
                                                color: isOver
                                                    ? Colors.redAccent
                                                    : (isWarn
                                                          ? Colors.amberAccent
                                                          : AppColors.success),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isOver
                                                ? '${lang.getText('budget_exceeded_by')} ${NumberFormat.currency(symbol: AppConstants.defaultCurrency, decimalDigits: 0).format(totalSpent - budget)}'
                                                : '${(ratio * 100).toStringAsFixed(0)}% ${lang.getText('of_limit')} ${NumberFormat.currency(symbol: AppConstants.defaultCurrency, decimalDigits: 0).format(budget)}',
                                            style: TextStyle(
                                              color: isOver
                                                  ? Colors.redAccent.shade100
                                                  : Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (!isOver)
                                            Text(
                                              '${NumberFormat.currency(symbol: AppConstants.defaultCurrency, decimalDigits: 0).format(budgetRemaining)} ${lang.getText('left')}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.85,
                                                ),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 5. 2x2 Bento Metric Grid (Inspired by the To-Do List section from Dribbble)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Column 1
                          Expanded(
                            child: Column(
                              children: [
                                _buildBentoCard(
                                  theme: theme,
                                  isDark: isDark,
                                  bgLight: const Color(
                                    0xFFEEF2FF,
                                  ), // Soft Indigo
                                  icon: Icons.receipt_long_rounded,
                                  iconColor: const Color(0xFF4F46E5),
                                  title: '${expenses.length}',
                                  subtitle: lang.getText('transactions'),
                                ),
                                const SizedBox(height: 12),
                                _buildBentoCard(
                                  theme: theme,
                                  isDark: isDark,
                                  bgLight: const Color(0xFFDCFCE7), // Soft Mint
                                  icon: Icons.trending_up_rounded,
                                  iconColor: const Color(0xFF10B981),
                                  title: NumberFormat.currency(
                                    symbol: AppConstants.defaultCurrency,
                                    decimalDigits: 1,
                                  ).format(dailyAverage),
                                  subtitle: lang.getText('daily_avg'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Column 2
                          Expanded(
                            child: Column(
                              children: [
                                _buildBentoCard(
                                  theme: theme,
                                  isDark: isDark,
                                  bgLight: const Color(
                                    0xFFFEF3C7,
                                  ), // Soft Amber
                                  icon: Icons.account_balance_wallet_rounded,
                                  iconColor: const Color(0xFFD97706),
                                  title: hasBudget
                                      ? NumberFormat.currency(
                                          symbol: AppConstants.defaultCurrency,
                                          decimalDigits: 0,
                                        ).format(
                                          budgetRemaining.clamp(0, 9999999),
                                        )
                                      : lang.getText('no_limit'),
                                  subtitle: lang.getText('budget_left'),
                                ),
                                const SizedBox(height: 12),
                                _buildBentoCard(
                                  theme: theme,
                                  isDark: isDark,
                                  bgLight: const Color(0xFFFCE7F3), // Soft Rose
                                  icon: Icons.local_fire_department_rounded,
                                  iconColor: const Color(0xFFDB2777),
                                  title: topCategoryName == 'None'
                                      ? lang.getText('none')
                                      : lang.getCategory(topCategoryName),
                                  subtitle: lang.getText('top_spending'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 6. Category Filter Carousel ("Focus Categories")
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang.getText('categories'),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (provider.selectedCategory != 'All')
                                InkWell(
                                  onTap: () =>
                                      provider.setSelectedCategory('All'),
                                  child: Text(
                                    lang.getText('clear'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 44,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildCreativeCategoryPill('All', provider, lang),
                              ...AppConstants.categories.map(
                                (cat) => _buildCreativeCategoryPill(
                                  cat,
                                  provider,
                                  lang,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 7. Recent Transactions Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.getText('recent_transactions'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (provider.selectedDate != null ||
                                  !provider.isCurrentMonth ||
                                  provider.selectedCategory != 'All')
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    [
                                      if (provider.selectedDate != null)
                                        DateFormat(
                                          'MMM dd',
                                        ).format(provider.selectedDate!)
                                      else if (!provider.isCurrentMonth)
                                        DateFormat(
                                          'MMM yyyy',
                                        ).format(provider.selectedMonth),
                                      if (provider.selectedCategory != 'All')
                                        lang.getCategory(
                                          provider.selectedCategory,
                                        ),
                                    ].join(' • '),
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (provider.selectedCategory != 'All' ||
                              provider.selectedDate != null ||
                              !provider.isCurrentMonth)
                            TextButton(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () {
                                provider.setSelectedCategory('All');
                                provider.resetToCurrentMonth();
                              },
                              child: Text(lang.getText('reset')),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 8. Content Area: Loading, Error, Empty, or List
                  if (provider.isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.errorMessage != null &&
                      provider.allExpenses.isEmpty)
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
                        actionLabel: lang.getText('add_expense'),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final expense = expenses[index];
                          return ExpenseTile(
                            expense: expense,
                            onTap: () => _openExpenseForm(expense),
                            onDelete: () {
                              final deletedId = expense.id;
                              final deletedTitle = expense.title;
                              provider.deleteExpense(deletedId);
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Moved "$deletedTitle" to Recycle Bin',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: lang.getText('undo'),
                                    textColor: Colors.amberAccent,
                                    onPressed: () {
                                      provider.restoreExpense(deletedId);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }, childCount: expenses.length),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 2x2 Bento Metric Card Widget
  Widget _buildBentoCard({
    required ThemeData theme,
    required bool isDark,
    required Color bgLight,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? iconColor.withValues(alpha: 0.15)
                      : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF18181B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Modern category pill chip
  Widget _buildCreativeCategoryPill(
    String category,
    ExpenseProvider provider, [
    LanguageProvider? lang,
  ]) {
    final isSelected = provider.selectedCategory == category;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = category == 'All'
        ? (lang?.getText('all') ?? 'All')
        : (lang?.getCategory(category) ?? category);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => provider.setSelectedCategory(category),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF18181B))
                : (isDark ? AppColors.surfaceDark : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.06)),
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category != 'All') ...[
                Icon(
                  AppConstants.getCategoryIcon(category),
                  size: 15,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : AppConstants.getCategoryColor(category),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
