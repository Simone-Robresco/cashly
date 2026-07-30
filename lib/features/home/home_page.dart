import 'package:flutter/material.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import '../../data/models/expense_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/transaction_view.dart';
import '../../core/widgets/transaction_tile.dart';
import '../expense_detail/expense_detail_page.dart';
import '../income_detail/income_detail_page.dart';
import '../settings/settings_page.dart';
import 'widgets/home_summary_card.dart';
import 'widgets/monthly_history_card.dart';

const String _euro = '\u20AC';

class HomePage extends StatefulWidget {
  final VoidCallback onSeeAllTap;

  const HomePage({super.key, required this.onSeeAllTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ExpenseRepository.instance, IncomeRepository.instance]),
      builder: (context, _) {
        final allExpenses = ExpenseRepository.instance.expenses;
        final allIncomes = IncomeRepository.instance.incomes;

        final monthExpenses = allExpenses
            .where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month)
            .toList();
        final monthIncomes = allIncomes
            .where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month)
            .toList();

        final categoryTotals = _computeCategoryTotals(monthExpenses);
        final totalExpense = categoryTotals.fold<double>(0, (sum, c) => sum + c.amount);
        final totalIncome = monthIncomes.fold<double>(0, (sum, e) => sum + e.amount);
        final averagePerExpense = monthExpenses.isEmpty ? 0.0 : totalExpense / monthExpenses.length;

        final transactions = <TransactionView>[
          ...monthExpenses.map(TransactionView.fromExpense),
          ...monthIncomes.map(TransactionView.fromIncome),
        ]..sort((a, b) => b.date.compareTo(a.date));
        final recentTransactions = transactions.take(10).toList();

        return Scaffold(
          body: SafeArea(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    HomeSummaryCard(
                      categoryTotals: categoryTotals,
                      total: totalExpense,
                      averagePerExpense: averagePerExpense,
                      expenseCount: monthExpenses.length,
                      selectedMonth: _selectedMonth,
                      availableMonths: _availableMonths(allExpenses, allIncomes),
                      onMonthSelected: (month) => setState(() => _selectedMonth = month),
                      onMoreTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
                      },
                    ),
                    const SizedBox(height: 16),
                    _BalanceRow(income: totalIncome, expense: totalExpense),
                    const SizedBox(height: 16),
                    MonthlyHistoryCard(
                      transactions: recentTransactions,
                      onSeeAllTap: widget.onSeeAllTap,
                      onTransactionTap: (t) {
                        if (t.isIncome) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => IncomeDetailPage(incomeId: t.id)));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExpenseDetailPage(expenseId: t.id)));
                        }
                      },
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DateTime> _availableMonths(List<ExpenseModel> expenses, List<dynamic> incomes) {
    final now = DateTime.now();
    final set = <DateTime>{DateTime(now.year, now.month)};
    for (final e in expenses) {
      set.add(DateTime(e.date.year, e.date.month));
    }
    for (final e in incomes) {
      set.add(DateTime(e.date.year, e.date.month));
    }
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  List<CategoryTotal> _computeCategoryTotals(List<ExpenseModel> expenses) {
    final Map<String, CategoryTotal> totals = {};
    for (final e in expenses) {
      final existing = totals[e.category.id];
      totals[e.category.id] = CategoryTotal(category: e.category, amount: (existing?.amount ?? 0) + e.amount);
    }
    final list = totals.values.toList()..sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }
}

class _BalanceRow extends StatelessWidget {
  final double income;
  final double expense;

  const _BalanceRow({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Row(
          children: [
            Expanded(child: _MiniStat(label: 'Entrate', value: income, color: incomeColor)),
            Container(width: 1, height: 34, color: AppColors.divider),
            Expanded(child: _MiniStat(label: 'Uscite', value: expense, color: AppColors.textPrimary)),
            Container(width: 1, height: 34, color: AppColors.divider),
            Expanded(child: _MiniStat(label: 'Saldo', value: balance, color: balance >= 0 ? incomeColor : AppColors.error)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(2)} $_euro', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}
