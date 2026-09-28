import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';

/// Interactive Analytics Card with Pie (Donut) Chart & Bar Chart view options.
class MonthlyAnalyticsCard extends StatefulWidget {
  final Map<String, double> categoryBreakdown;
  final double totalAmount;
  final String periodTitle;

  const MonthlyAnalyticsCard({
    super.key,
    required this.categoryBreakdown,
    required this.totalAmount,
    required this.periodTitle,
  });

  @override
  State<MonthlyAnalyticsCard> createState() => _MonthlyAnalyticsCardState();
}

class _MonthlyAnalyticsCardState extends State<MonthlyAnalyticsCard> {
  bool _showBarChart = false;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // If there is no expense data for this period
    if (widget.totalAmount <= 0 || widget.categoryBreakdown.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.pie_chart_outline_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Analytics Data',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Add an expense in ${widget.periodTitle} to view spending breakdown.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Sort entries by amount descending
    final sortedEntries = widget.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Toggle (Pie vs Bar)
          Row(
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
                      _showBarChart ? Icons.bar_chart_rounded : Icons.pie_chart_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending by Category',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.periodTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Segmented Toggle Button
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showBarChart = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: !_showBarChart ? theme.colorScheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.pie_chart_rounded,
                          size: 16,
                          color: !_showBarChart
                              ? Colors.white
                              : (isDark ? Colors.white60 : Colors.black54),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showBarChart = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _showBarChart ? theme.colorScheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.bar_chart_rounded,
                          size: 16,
                          color: _showBarChart
                              ? Colors.white
                              : (isDark ? Colors.white60 : Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart Area: Donut Chart or Bar Chart
          if (!_showBarChart)
            _buildDonutChartView(sortedEntries, theme, isDark)
          else
            _buildBarChartView(sortedEntries, theme, isDark),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Category Legend Grid
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: sortedEntries.map((entry) {
              final cat = entry.key;
              final amount = entry.value;
              final pct = (amount / widget.totalAmount * 100).toStringAsFixed(1);
              final color = AppConstants.getCategoryColor(cat);
              final isHovered = _selectedCategory == cat;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = (_selectedCategory == cat) ? null : cat;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? color.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isHovered ? color : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
                          color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds Donut Chart layout with central stats
  Widget _buildDonutChartView(
    List<MapEntry<String, double>> entries,
    ThemeData theme,
    bool isDark,
  ) {
    final highlightedEntry = _selectedCategory != null
        ? entries.firstWhere(
            (e) => e.key == _selectedCategory,
            orElse: () => entries.first,
          )
        : null;

    final centerLabel = highlightedEntry != null
        ? highlightedEntry.key
        : 'Total Spent';
    final centerAmount = highlightedEntry != null
        ? highlightedEntry.value
        : widget.totalAmount;

    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(180, 180),
              painter: DonutChartPainter(
                entries: entries,
                totalAmount: widget.totalAmount,
                selectedCategory: _selectedCategory,
                strokeWidth: 26,
              ),
            ),
            // Center info pill
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  NumberFormat.currency(
                    symbol: AppConstants.defaultCurrency,
                    decimalDigits: 0,
                  ).format(centerAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds horizontal proportional bar chart
  Widget _buildBarChartView(
    List<MapEntry<String, double>> entries,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: entries.map((entry) {
        final cat = entry.key;
        final amount = entry.value;
        final ratio = (amount / widget.totalAmount).clamp(0.0, 1.0);
        final color = AppConstants.getCategoryColor(cat);
        final icon = AppConstants.getCategoryIcon(cat);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 6),
                      Text(
                        cat,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: AppConstants.defaultCurrency,
                      decimalDigits: 2,
                    ).format(amount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// CustomPainter for rendering animated smooth donut arcs
class DonutChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double totalAmount;
  final String? selectedCategory;
  final double strokeWidth;

  DonutChartPainter({
    required this.entries,
    required this.totalAmount,
    required this.selectedCategory,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalAmount <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    double startAngle = -math.pi / 2;
    const gapAngle = 0.04; // small gap between slices

    for (final entry in entries) {
      final sweepAngle = (entry.value / totalAmount) * 2 * math.pi;
      final color = AppConstants.getCategoryColor(entry.key);
      final isSelected = selectedCategory == entry.key;

      final paint = Paint()
        ..color = (selectedCategory != null && !isSelected)
            ? color.withValues(alpha: 0.35)
            : color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 4 : strokeWidth
        ..strokeCap = StrokeCap.round;

      final actualSweep = math.max(0.01, sweepAngle - gapAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gapAngle / 2),
        actualSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.totalAmount != totalAmount ||
        oldDelegate.selectedCategory != selectedCategory;
  }
}
