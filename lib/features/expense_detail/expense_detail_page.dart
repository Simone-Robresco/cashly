import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_labels.dart';
import '../expense_create/create_expense_page.dart';

const String _euro = '\u20AC';

class ExpenseDetailPage extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailPage({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ExpenseRepository.instance,
      builder: (context, _) {
        final matches = ExpenseRepository.instance.expenses.where((e) => e.id == expenseId);
        if (matches.isEmpty) {
          // La spesa è stata eliminata: torna indietro.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        final expense = matches.first;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dettagli spesa'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CreateExpensePage(existingExpense: expense)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: () => _confirmDelete(context, expense),
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
                      backgroundColor: expense.category.color,
                      child: Icon(expense.category.icon, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      expense.productName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '- ${expense.amount.toStringAsFixed(2)} $_euro',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: expense.category.color),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: expense.category.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(expense.category.icon, size: 16, color: expense.category.color),
                          const SizedBox(width: 6),
                          Text(
                            expense.category.name,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: expense.category.color),
                          ),
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
                      _DetailRow(icon: Icons.calendar_today_rounded, label: 'Data', value: fullDateLabel(expense.date)),
                      const SizedBox(height: 18),
                      const Text('Descrizione', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                        (expense.description == null || expense.description!.isEmpty)
                            ? 'Nessuna descrizione'
                            : expense.description!,
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

  void _confirmDelete(BuildContext context, ExpenseModel expense) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminare la spesa?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '"${expense.productName}" verrà eliminata definitivamente.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annulla', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ExpenseRepository.instance.deleteExpense(expense.id);
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
