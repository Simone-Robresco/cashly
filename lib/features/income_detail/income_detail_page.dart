import 'package:flutter/material.dart';
import '../../data/models/income_model.dart';
import '../../data/repositories/income_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_labels.dart';
import '../../core/widgets/transaction_tile.dart';
import '../income_create/create_income_page.dart';

const String _euro = '\u20AC';

class IncomeDetailPage extends StatelessWidget {
  final String incomeId;

  const IncomeDetailPage({super.key, required this.incomeId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: IncomeRepository.instance,
      builder: (context, _) {
        final matches = IncomeRepository.instance.incomes.where((e) => e.id == incomeId);
        if (matches.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        final income = matches.first;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dettagli entrata'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateIncomePage(existingIncome: income)));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: () => _confirmDelete(context, income),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: income.category.color,
                      child: Icon(income.category.icon, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      income.productName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '+ ${income.amount.toStringAsFixed(2)} $_euro',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: incomeColor),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: income.category.color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(income.category.icon, size: 16, color: income.category.color),
                          const SizedBox(width: 6),
                          Text(income.category.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: income.category.color)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dettagli', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          const Text('Data', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(fullDateLabel(income.date), style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text('Descrizione', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                        (income.description == null || income.description!.isEmpty) ? 'Nessuna descrizione' : income.description!,
                        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, IncomeModel income) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminare l\'entrata?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('"${income.productName}" verrà eliminata definitivamente.', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Annulla', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              IncomeRepository.instance.deleteIncome(income.id);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Elimina', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
