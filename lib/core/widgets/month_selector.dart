import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/date_labels.dart';

/// Pulsante "Luglio 2026" con freccia, che apre un menù per scegliere un
/// altro mese tra quelli disponibili. Usato sia in Home sia nei Grafici.
class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final List<DateTime> availableMonths;
  final ValueChanged<DateTime> onSelected;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.availableMonths,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DateTime>(
      color: AppColors.surface,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: onSelected,
      itemBuilder: (context) {
        return availableMonths.map((month) {
          final isSelected = month.year == selectedMonth.year && month.month == selectedMonth.month;
          return PopupMenuItem<DateTime>(
            value: month,
            child: Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check_rounded, size: 18, color: AppColors.accent)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 10),
                Text(
                  monthYearLabel(month),
                  style: TextStyle(
                    color: isSelected ? AppColors.accent : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(
              monthYearLabel(selectedMonth),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
