import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';
import '../constants/app_colors.dart';

const String _euro = '\u20AC';

/// Riga di una spesa: icona colorata della categoria, nome in grassetto,
/// categoria in grigio sotto, prezzo in grassetto a destra. Usata sia
/// nello storico della home sia nella pagina storico completa.
class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap;

  const ExpenseTile({super.key, required this.expense, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: expense.category.color.withValues(alpha: 0.22),
              child: Icon(expense.category.icon, color: expense.category.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expense.productName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.category.name,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${expense.amount.toStringAsFixed(2)} $_euro',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
