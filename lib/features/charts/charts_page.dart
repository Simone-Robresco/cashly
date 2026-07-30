import 'package:flutter/material.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/category_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/month_selector.dart';

const String _euro = '\u20AC';
const List<String> _monthAbbrev = [
  'Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic',
];
const List<String> _weekdayAbbrev = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  late DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grafici')),
      body: AnimatedBuilder(
        animation: ExpenseRepository.instance,
        builder: (context, _) {
          final all = ExpenseRepository.instance.expenses;
          final monthExpenses = all
              .where((e) => e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month)
              .toList();

          final total = monthExpenses.fold<double>(0, (s, e) => s + e.amount);
          final categoryTotals = _byCategory(monthExpenses);
          final prevMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
          final prevTotal = all
              .where((e) => e.date.year == prevMonth.year && e.date.month == prevMonth.month)
              .fold<double>(0, (s, e) => s + e.amount);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              MonthSelector(
                selectedMonth: _selectedMonth,
                availableMonths: _availableMonths(all),
                onSelected: (m) => setState(() => _selectedMonth = m),
              ),
              const SizedBox(height: 16),

              _QuickStatsRow(total: total, count: monthExpenses.length),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Confronto con il mese precedente',
                child: _DeltaRow(current: total, previous: prevTotal),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Spese per categoria',
                child: categoryTotals.isEmpty
                    ? const _EmptyHint()
                    : _BarList(rows: _categoryBarRows(categoryTotals, byAverage: false)),
              ),
              const SizedBox(height: 16),

              if (categoryTotals.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: _HighlightTile(
                        label: 'Categoria più costosa',
                        icon: categoryTotals.first.category.icon,
                        color: categoryTotals.first.category.color,
                        title: categoryTotals.first.category.name,
                        value: '${categoryTotals.first.amount.toStringAsFixed(2)} $_euro',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HighlightTile(
                        label: 'Più frequente',
                        icon: _mostFrequent(categoryTotals).category.icon,
                        color: _mostFrequent(categoryTotals).category.color,
                        title: _mostFrequent(categoryTotals).category.name,
                        value: '${_mostFrequent(categoryTotals).count} spese',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              _SectionCard(
                title: 'Media per categoria',
                child: categoryTotals.isEmpty
                    ? const _EmptyHint()
                    : _BarList(rows: _categoryBarRows(categoryTotals, byAverage: true)),
              ),
              const SizedBox(height: 16),

              if (monthExpenses.isNotEmpty) ...[
                _SectionCard(
                  title: 'Spesa più alta del mese',
                  child: _buildTopExpense(monthExpenses),
                ),
                const SizedBox(height: 16),
              ],

              _SectionCard(
                title: 'Spese per giorno della settimana',
                child: monthExpenses.isEmpty ? const _EmptyHint() : _BarList(rows: _weekdayBarRows(monthExpenses)),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Distribuzione per importo',
                child: monthExpenses.isEmpty ? const _EmptyHint() : _BarList(rows: _bucketBarRows(monthExpenses)),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Andamento cumulativo nel mese',
                child: _SimpleBarChart(points: _cumulativeByWeek(monthExpenses, _selectedMonth)),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Andamento negli ultimi 6 mesi',
                child: _SimpleBarChart(points: _lastSixMonths(all)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopExpense(List<ExpenseModel> monthExpenses) {
    final top = monthExpenses.reduce((a, b) => a.amount >= b.amount ? a : b);
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: top.category.color.withValues(alpha: 0.16),
          child: Icon(top.category.icon, color: top.category.color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(top.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(top.category.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Text(
          '${top.amount.toStringAsFixed(2)} $_euro',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  List<DateTime> _availableMonths(List<ExpenseModel> all) {
    final now = DateTime.now();
    final set = <DateTime>{DateTime(now.year, now.month)};
    for (final e in all) {
      set.add(DateTime(e.date.year, e.date.month));
    }
    final list = set.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  List<_CategoryTotal> _byCategory(List<ExpenseModel> expenses) {
    final map = <String, _CategoryTotal>{};
    for (final e in expenses) {
      final existing = map[e.category.id];
      map[e.category.id] = _CategoryTotal(
        category: e.category,
        amount: (existing?.amount ?? 0) + e.amount,
        count: (existing?.count ?? 0) + 1,
      );
    }
    final list = map.values.toList()..sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  _CategoryTotal _mostFrequent(List<_CategoryTotal> totals) {
    final sorted = List<_CategoryTotal>.from(totals)..sort((a, b) => b.count.compareTo(a.count));
    return sorted.first;
  }

  List<_BarRow> _categoryBarRows(List<_CategoryTotal> totals, {required bool byAverage}) {
    final values = totals.map((t) => byAverage ? t.amount / t.count : t.amount).toList();
    final maxValue = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final sortedIndexes = List.generate(totals.length, (i) => i)
      ..sort((a, b) => values[b].compareTo(values[a]));

    return sortedIndexes.map((i) {
      final t = totals[i];
      final value = values[i];
      return _BarRow(
        label: t.category.name,
        color: t.category.color,
        valueText: '${value.toStringAsFixed(2)} $_euro',
        barFactor: maxValue > 0 ? value / maxValue : 0,
      );
    }).toList();
  }

  List<_BarRow> _weekdayBarRows(List<ExpenseModel> expenses) {
    final totals = List<double>.filled(7, 0);
    for (final e in expenses) {
      totals[e.date.weekday - 1] += e.amount;
    }
    final maxValue = totals.reduce((a, b) => a > b ? a : b);
    return List.generate(7, (i) {
      return _BarRow(
        label: _weekdayAbbrev[i],
        color: AppColors.accent,
        valueText: '${totals[i].toStringAsFixed(0)} $_euro',
        barFactor: maxValue > 0 ? totals[i] / maxValue : 0,
      );
    });
  }

  List<_BarRow> _bucketBarRows(List<ExpenseModel> expenses) {
    int small = 0, medium = 0, large = 0;
    for (final e in expenses) {
      if (e.amount < 10) {
        small++;
      } else if (e.amount <= 50) {
        medium++;
      } else {
        large++;
      }
    }
    final maxCount = [small, medium, large].reduce((a, b) => a > b ? a : b);
    return [
      _BarRow(label: 'Piccole (< 10 $_euro)', color: AppColors.accent, valueText: '$small spese', barFactor: maxCount > 0 ? small / maxCount : 0),
      _BarRow(label: 'Medie (10-50 $_euro)', color: AppColors.accent, valueText: '$medium spese', barFactor: maxCount > 0 ? medium / maxCount : 0),
      _BarRow(label: 'Grandi (> 50 $_euro)', color: AppColors.accent, valueText: '$large spese', barFactor: maxCount > 0 ? large / maxCount : 0),
    ];
  }

  List<_ChartPoint> _cumulativeByWeek(List<ExpenseModel> monthExpenses, DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final weeks = (daysInMonth / 7).ceil();
    final sorted = List<ExpenseModel>.from(monthExpenses)..sort((a, b) => a.date.compareTo(b.date));

    final points = <_ChartPoint>[];
    for (int w = 0; w < weeks; w++) {
      final weekEndDay = ((w + 1) * 7).clamp(0, daysInMonth);
      final cumulative = sorted.where((e) => e.date.day <= weekEndDay).fold<double>(0, (s, e) => s + e.amount);
      points.add(_ChartPoint(label: 'Sett. ${w + 1}', amount: cumulative));
    }
    return points;
  }

  List<_ChartPoint> _lastSixMonths(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final points = <_ChartPoint>[];
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final amount = expenses
          .where((e) => e.date.year == d.year && e.date.month == d.month)
          .fold<double>(0, (s, e) => s + e.amount);
      points.add(_ChartPoint(label: _monthAbbrev[d.month - 1], amount: amount));
    }
    return points;
  }
}

class _CategoryTotal {
  final CategoryModel category;
  final double amount;
  final int count;
  _CategoryTotal({required this.category, required this.amount, required this.count});
}

class _ChartPoint {
  final String label;
  final double amount;
  _ChartPoint({required this.label, required this.amount});
}

class _BarRow {
  final String label;
  final Color color;
  final String valueText;
  final double barFactor;
  _BarRow({required this.label, required this.color, required this.valueText, required this.barFactor});
}

/// Card con titolo, usata da quasi tutte le sezioni della pagina.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return const Text('Nessuna spesa in questo mese', style: TextStyle(color: AppColors.textSecondary));
  }
}

/// Tre numeri rapidi: totale, numero di spese, media per spesa.
class _QuickStatsRow extends StatelessWidget {
  final double total;
  final int count;

  const _QuickStatsRow({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    final avg = count == 0 ? 0.0 : total / count;
    return Row(
      children: [
        Expanded(child: _StatBox(label: 'Totale', value: '${total.toStringAsFixed(0)} $_euro')),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(label: 'Spese', value: '$count')),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(label: 'Media', value: '${avg.toStringAsFixed(2)} $_euro')),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Differenza rispetto al mese precedente, con freccia su/giù colorata.
class _DeltaRow extends StatelessWidget {
  final double current;
  final double previous;

  const _DeltaRow({required this.current, required this.previous});

  @override
  Widget build(BuildContext context) {
    String changeText;
    Color changeColor;
    IconData changeIcon;

    if (previous <= 0) {
      changeText = current > 0 ? 'Nessun dato nel mese precedente' : 'Nessun dato da confrontare';
      changeColor = AppColors.textSecondary;
      changeIcon = Icons.remove_rounded;
    } else {
      final pct = (current - previous) / previous * 100;
      final up = pct > 0;
      changeText = '${up ? '+' : ''}${pct.toStringAsFixed(1)}%';
      changeColor = up ? AppColors.error : const Color(0xFF2E9E6B);
      changeIcon = up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    }

    return Row(
      children: [
        Icon(changeIcon, color: changeColor, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(changeText, style: TextStyle(color: changeColor, fontWeight: FontWeight.w700, fontSize: 15)),
        ),
        Text(
          '${previous.toStringAsFixed(2)} $_euro → ${current.toStringAsFixed(2)} $_euro',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

/// Riquadro con icona colorata, titolo e valore: per "categoria più
/// costosa", "più frequente", ecc.
class _HighlightTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _HighlightTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: color.withValues(alpha: 0.16), child: Icon(icon, color: color, size: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}

/// Elenco di barre orizzontali: usato per categorie, giorni della
/// settimana, fasce di importo.
class _BarList extends StatelessWidget {
  final List<_BarRow> rows;

  const _BarList({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(row.valueText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(height: 8, color: AppColors.divider),
                        Container(height: 8, width: constraints.maxWidth * row.barFactor, color: row.color),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Grafico a barre verticali generico (usato per il trend mensile e per
/// l'andamento cumulativo). Nessuna altezza fissata a mano: ogni colonna
/// si dimensiona da sola, quindi non sfora mai.
class _SimpleBarChart extends StatelessWidget {
  final List<_ChartPoint> points;
  static const double maxBarHeight = 100.0;

  const _SimpleBarChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxAmount = points.fold<double>(0, (m, p) => p.amount > m ? p.amount : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: points.map((point) {
        final barHeight = maxAmount > 0 ? (point.amount / maxAmount) * maxBarHeight : 0.0;
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                point.amount > 0 ? point.amount.toStringAsFixed(0) : '',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Container(
                height: barHeight < 4 ? 4 : barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                point.label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
