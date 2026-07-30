import 'package:flutter/material.dart';
import '../models/transaction_view.dart';
import '../constants/app_colors.dart';

const String _euro = '\u20AC';
const Color incomeColor = Color(0xFF2E9E6B);

class TransactionTile extends StatelessWidget {
  final TransactionView transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isIncome ? incomeColor : AppColors.textPrimary;
    final sign = transaction.isIncome ? '+ ' : '- ';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: transaction.categoryColor.withValues(alpha: 0.18),
              child: Icon(transaction.categoryIcon, color: transaction.categoryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(transaction.categoryName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sign${transaction.amount.toStringAsFixed(2)} $_euro',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}
