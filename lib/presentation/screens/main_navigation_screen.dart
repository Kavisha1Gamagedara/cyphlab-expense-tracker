import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/expense_provider.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';
import 'expense_form.dart';

/// Main navigation shell hosting Home (Expenses Dashboard) and Analytics with modern NavigationBar.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    AnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Start listening to the Firestore stream once for the app shell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().startListening();
    });
  }

  void _openExpenseForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ExpenseForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openExpenseForm,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          highlightElevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'Add Expense',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          height: 65,
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: theme.colorScheme.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded, color: theme.colorScheme.primary),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }
}
