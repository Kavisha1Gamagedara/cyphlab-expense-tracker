import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';

/// Monthly Budgeting Card displaying spending vs budget target, warning status, and cumulative spending line chart.
class MonthlyBudgetCard extends StatelessWidget {
  final double spentAmount;
  final double? budgetAmount;
  final String periodTitle;
  final Map<int, double> cumulativeSpending;
  final int totalDays;
  final VoidCallback onSetBudget;

  const MonthlyBudgetCard({
    super.key,
    required this.spentAmount,
    required this.budgetAmount,
    required this.periodTitle,
    required this.cumulativeSpending,
    required this.totalDays,
    required this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasBudget = budgetAmount != null && budgetAmount! > 0;
    final budget = budgetAmount ?? 0.0;
    final percentage = hasBudget ? (spentAmount / budget) : 0.0;
    final isExceeded = hasBudget && spentAmount > budget;
    final isWarning = hasBudget && !isExceeded && percentage >= 0.80; // 80% warning threshold

    // Status colors
    final Color statusColor = isExceeded
        ? AppColors.error
        : (isWarning ? AppColors.warning : AppColors.success);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isExceeded
              ? AppColors.error.withValues(alpha: 0.4)
              : (isWarning
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
          width: (isExceeded || isWarning) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isExceeded || isWarning)
                ? statusColor.withValues(alpha: isDark ? 0.2 : 0.08)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title + Set/Edit Budget button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isExceeded
                          ? Icons.warning_rounded
                          : (isWarning
                              ? Icons.notification_important_rounded
                              : Icons.savings_rounded),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Budget Target',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        periodTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: onSetBudget,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasBudget ? Icons.edit_rounded : Icons.add_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasBudget ? 'Edit Limit' : 'Set Limit',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Budget Numbers Display
          if (hasBudget) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent so far',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      NumberFormat.currency(
                        symbol: AppConstants.defaultCurrency,
                        decimalDigits: 2,
                      ).format(spentAmount),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        color: isExceeded ? AppColors.error : null,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Budget Limit',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      NumberFormat.currency(
                        symbol: AppConstants.defaultCurrency,
                        decimalDigits: 0,
                      ).format(budget),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Progress Bar with Status Alert Pill
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage.clamp(0.0, 1.0),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Status message and remaining amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isExceeded
                          ? Icons.cancel_rounded
                          : (isWarning ? Icons.warning_amber_rounded : Icons.check_circle_rounded),
                      size: 15,
                      color: statusColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isExceeded
                          ? 'Budget Exceeded!'
                          : (isWarning ? 'Approaching Limit (${(percentage * 100).toStringAsFixed(0)}%)' : 'On Track (${(percentage * 100).toStringAsFixed(0)}%)'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  isExceeded
                      ? '+${NumberFormat.currency(symbol: AppConstants.defaultCurrency, decimalDigits: 0).format(spentAmount - budget)} over'
                      : '${NumberFormat.currency(symbol: AppConstants.defaultCurrency, decimalDigits: 0).format(budget - spentAmount)} left',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Prompt to set budget
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No spending limit set for this month. Set a target to keep track of your budget progression!',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Section Title: Cumulative Spending Line Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Progression',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 3,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Actual',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (hasBudget) ...[
                    const SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 1.5,
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Limit',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Line Chart Canvas
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: BudgetLineChartPainter(
                cumulativeSpending: cumulativeSpending,
                budgetAmount: budgetAmount,
                totalDays: totalDays,
                lineColor: theme.colorScheme.primary,
                budgetColor: isExceeded ? AppColors.error : AppColors.warning,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Day Axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day 1',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                'Day ${(totalDays / 2).round()}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                'Day $totalDays',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// CustomPainter that renders an attractive cumulative expenditure curve with gradient fill and dotted/dashed budget limit line.
class BudgetLineChartPainter extends CustomPainter {
  final Map<int, double> cumulativeSpending;
  final double? budgetAmount;
  final int totalDays;
  final Color lineColor;
  final Color budgetColor;
  final bool isDark;

  BudgetLineChartPainter({
    required this.cumulativeSpending,
    required this.budgetAmount,
    required this.totalDays,
    required this.lineColor,
    required this.budgetColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalDays <= 0) return;

    final paddingBottom = 16.0;
    final paddingTop = 12.0;
    final chartHeight = size.height - paddingBottom - paddingTop;
    final chartWidth = size.width;

    // Determine max value for Y-axis scaling
    double maxSpending = 0.0;
    for (final val in cumulativeSpending.values) {
      if (val > maxSpending) maxSpending = val;
    }
    final budget = budgetAmount ?? 0.0;
    final maxY = math.max(maxSpending, budget) * 1.15;
    if (maxY <= 0) return;

    // Draw horizontal background gridlines (2 lines)
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, paddingTop + chartHeight * 0.5),
      Offset(chartWidth, paddingTop + chartHeight * 0.5),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, paddingTop + chartHeight),
      Offset(chartWidth, paddingTop + chartHeight),
      gridPaint,
    );

    // Draw Budget Reference Line (dashed line)
    if (budget > 0) {
      final budgetY = paddingTop + chartHeight * (1.0 - (budget / maxY).clamp(0.0, 1.0));
      final budgetPaint = Paint()
        ..color = budgetColor.withValues(alpha: 0.75)
        ..strokeWidth = 1.5;

      const dashWidth = 5.0;
      const dashSpace = 4.0;
      double startX = 0.0;
      while (startX < chartWidth) {
        canvas.drawLine(
          Offset(startX, budgetY),
          Offset(math.min(startX + dashWidth, chartWidth), budgetY),
          budgetPaint,
        );
        startX += dashWidth + dashSpace;
      }
    }

    if (cumulativeSpending.isEmpty) return;

    // Build smooth cubic bezier curve for cumulative spending
    final points = <Offset>[];
    final sortedDays = cumulativeSpending.keys.toList()..sort();

    for (final day in sortedDays) {
      final x = ((day - 1) / (totalDays - 1)) * chartWidth;
      final y = paddingTop + chartHeight * (1.0 - (cumulativeSpending[day]! / maxY).clamp(0.0, 1.0));
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // Create Path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPointX = (p0.dx + p1.dx) / 2;
      path.cubicTo(
        controlPointX,
        p0.dy,
        controlPointX,
        p1.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Gradient fill under the curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, paddingTop + chartHeight)
      ..lineTo(points.first.dx, paddingTop + chartHeight)
      ..close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.35),
        lineColor.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(
        Rect.fromLTWH(0, paddingTop, chartWidth, chartHeight),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Draw glowing end dot at latest point
    final latestPoint = points.last;
    final dotShadowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(latestPoint, 7, dotShadowPaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(latestPoint, 4, dotPaint);

    final dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(latestPoint, 2, dotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant BudgetLineChartPainter oldDelegate) {
    return oldDelegate.cumulativeSpending != cumulativeSpending ||
        oldDelegate.budgetAmount != budgetAmount ||
        oldDelegate.totalDays != totalDays ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.budgetColor != budgetColor;
  }
}
