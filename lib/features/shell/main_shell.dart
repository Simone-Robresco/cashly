import 'package:flutter/material.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/accent_fab.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/transaction_tile.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import '../charts/charts_page.dart';
import '../expense_create/create_expense_page.dart';
import '../income_create/create_income_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HistoryPage(),
          HomePage(onSeeAllTap: () => setState(() => _index = 0)),
          const ChartsPage(),
        ],
      ),
      floatingActionButton: _index == 1
          ? AccentFab(onPressed: () => _showAddChoice(context))
          : null,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }

  Future<void> _showAddChoice(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0x1AD64545), child: Icon(Icons.remove_rounded, color: AppColors.error)),
                title: const Text('Nuova spesa', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.of(ctx).pop('expense'),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0x1A2E9E6B), child: Icon(Icons.add_rounded, color: incomeColor)),
                title: const Text('Nuova entrata', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.of(ctx).pop('income'),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || choice == null) return;
    if (choice == 'expense') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateExpensePage()));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateIncomePage()));
    }
  }
}
