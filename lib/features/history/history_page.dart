import 'package:flutter/material.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_labels.dart';
import '../../core/models/transaction_view.dart';
import '../../core/widgets/transaction_tile.dart';
import '../expense_detail/expense_detail_page.dart';
import '../income_detail/income_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storico')),
      body: AnimatedBuilder(
        animation: Listenable.merge([ExpenseRepository.instance, IncomeRepository.instance]),
        builder: (context, _) {
          final all = <TransactionView>[
            ...ExpenseRepository.instance.expenses.map(TransactionView.fromExpense),
            ...IncomeRepository.instance.incomes.map(TransactionView.fromIncome),
          ]..sort((a, b) => b.date.compareTo(a.date));

          final filtered = _query.isEmpty
              ? all
              : all.where((t) {
                  final q = _query.toLowerCase();
                  return t.title.toLowerCase().contains(q) || t.categoryName.toLowerCase().contains(q);
                }).toList();

          final groups = _groupByMonth(filtered);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cerca',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: groups.isEmpty
                    ? const Center(child: Text('Nessun movimento trovato', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: groups.length,
                        itemBuilder: (context, sectionIndex) {
                          final section = groups[sectionIndex];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                                child: Text(section.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              ),
                              Container(
                                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  itemCount: section.transactions.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1, indent: 60, color: AppColors.divider),
                                  itemBuilder: (context, i) {
                                    final t = section.transactions[i];
                                    return TransactionTile(
                                      transaction: t,
                                      onTap: () {
                                        if (t.isIncome) {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => IncomeDetailPage(incomeId: t.id)));
                                        } else {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExpenseDetailPage(expenseId: t.id)));
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_MonthSection> _groupByMonth(List<TransactionView> transactions) {
    final sections = <_MonthSection>[];
    for (final t in transactions) {
      final title = monthYearLabel(t.date);
      if (sections.isNotEmpty && sections.last.title == title) {
        sections.last.transactions.add(t);
      } else {
        sections.add(_MonthSection(title: title, transactions: [t]));
      }
    }
    return sections;
  }
}

class _MonthSection {
  final String title;
  final List<TransactionView> transactions;
  _MonthSection({required this.title, required this.transactions});
}
