import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../state/expense_provider.dart';

/// Modal bottom sheet allowing users to pick a specific Month/Year or Day
class CalendarSelectorSheet extends StatefulWidget {
  const CalendarSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CalendarSelectorSheet(),
    );
  }

  @override
  State<CalendarSelectorSheet> createState() => _CalendarSelectorSheetState();
}

class _CalendarSelectorSheetState extends State<CalendarSelectorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _focusedMonth;
  late DateTime? _focusedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final provider = context.read<ExpenseProvider>();
    _focusedMonth = provider.selectedMonth;
    _focusedDate = provider.selectedDate;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header title and Reset button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Select Period',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.today_rounded, size: 16),
                    label: const Text('Current Month'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      context.read<ExpenseProvider>().resetToCurrentMonth();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // Tabs: "Month Selector" and "Day Selector"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.primary,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? Colors.white60 : AppColors.textSecondaryLight,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_module_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('By Month'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_view_day_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('Specific Day'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tab View content
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 340),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMonthGridView(theme, isDark),
                  _buildDayCalendarView(theme, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grid view showing 12 months for the selected year
  Widget _buildMonthGridView(ThemeData theme, bool isDark) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final currentYear = DateTime.now().year;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Year Switcher Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year - 1, _focusedMonth.month);
                  });
                },
              ),
              Text(
                '${_focusedMonth.year}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year + 1, _focusedMonth.month);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final monthNum = index + 1;
                final isSelected = _focusedMonth.year == context.read<ExpenseProvider>().selectedMonth.year &&
                    monthNum == context.read<ExpenseProvider>().selectedMonth.month &&
                    context.read<ExpenseProvider>().selectedDate == null;
                final isCurrent = currentYear == _focusedMonth.year &&
                    monthNum == DateTime.now().month;

                return InkWell(
                  onTap: () {
                    final chosen = DateTime(_focusedMonth.year, monthNum);
                    context.read<ExpenseProvider>().setSelectedMonth(chosen);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isCurrent
                              ? theme.colorScheme.primary.withValues(alpha: 0.15)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.03))),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isCurrent
                                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                                : Colors.transparent),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      months[index],
                      style: TextStyle(
                        fontWeight: isSelected || isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isCurrent
                                ? theme.colorScheme.primary
                                : (isDark ? Colors.white : AppColors.textPrimaryLight)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive CalendarDatePicker view for selecting an exact single day
  Widget _buildDayCalendarView(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: theme.colorScheme.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: CalendarDatePicker(
          initialDate: _focusedDate ?? _focusedMonth,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          currentDate: DateTime.now(),
          onDateChanged: (pickedDate) {
            context.read<ExpenseProvider>().setSelectedDate(pickedDate);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
