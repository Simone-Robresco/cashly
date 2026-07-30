import 'dart:math';
import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/month_selector.dart';

const String _euro = '\u20AC';

/// Dato aggregato per categoria, usato dal toroide.
class CategoryTotal {
  final CategoryModel category;
  final double amount;

  const CategoryTotal({required this.category, required this.amount});
}

class HomeSummaryCard extends StatelessWidget {
  final List<CategoryTotal> categoryTotals;
  final double total;
  final double averagePerExpense;
  final int expenseCount;
  final DateTime selectedMonth;
  final List<DateTime> availableMonths;
  final ValueChanged<DateTime> onMonthSelected;
  final VoidCallback? onMoreTap;

  const HomeSummaryCard({
    super.key,
    required this.categoryTotals,
    required this.total,
    required this.averagePerExpense,
    required this.expenseCount,
    required this.selectedMonth,
    required this.availableMonths,
    required this.onMonthSelected,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MonthSelector(
                  selectedMonth: selectedMonth,
                  availableMonths: availableMonths,
                  onSelected: onMonthSelected,
                ),
                IconButton(
                  onPressed: onMoreTap,
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: _DonutChart(slices: categoryTotals, expenseCount: expenseCount),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TotalBlock(
                  label: 'Totale speso',
                  value: '${total.toStringAsFixed(2)} $_euro',
                  valueColor: AppColors.textPrimary,
                  valueSize: 22,
                ),
                Container(width: 1, height: 36, color: AppColors.divider),
                _TotalBlock(
                  label: 'Media spesa',
                  value: '${averagePerExpense.toStringAsFixed(2)} $_euro',
                  valueColor: AppColors.textSecondary,
                  valueSize: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double valueSize;

  const _TotalBlock({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// Toroide: ogni fetta è colorata in base alla percentuale di spesa della
/// categoria sul totale. Al centro, il numero di spese del mese scelto.
class _DonutChart extends StatelessWidget {
  final List<CategoryTotal> slices;
  final int expenseCount;

  const _DonutChart({required this.slices, required this.expenseCount});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutChartPainter(slices: slices),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$expenseCount',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            Text(
              expenseCount == 1 ? 'spesa' : 'spese',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategoryTotal> slices;
  static const double strokeWidth = 18;

  _DonutChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final total = slices.fold<double>(0, (sum, s) => sum + s.amount);
    if (total <= 0 || slices.isEmpty) return;

    double startAngle = -pi / 2;
    const gap = 0.025;

    for (final slice in slices) {
      final sweep = (slice.amount / total) * 2 * pi;
      final sliceStart = startAngle + gap / 2;
      final sliceSweep = max(sweep - gap, 0.001);

      final paint = Paint()
        ..color = slice.category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, sliceStart, sliceSweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
