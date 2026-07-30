import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/transaction_view.dart';
import '../../../core/widgets/transaction_tile.dart';

class MonthlyHistoryCard extends StatelessWidget {
  final List<TransactionView> transactions;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<TransactionView>? onTransactionTap;

  const MonthlyHistoryCard({
    super.key,
    required this.transactions,
    this.onSeeAllTap,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Storico del mese', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: onSeeAllTap,
                  child: const Text('Vedi tutte', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Nessun movimento questo mese', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: transactions.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 60, color: AppColors.divider),
              itemBuilder: (context, index) {
                final t = transactions[index];
                return TransactionTile(transaction: t, onTap: () => onTransactionTap?.call(t));
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
