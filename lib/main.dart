import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/income_repository.dart';
import 'features/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CategoryRepository.instance.init();
  await ExpenseRepository.instance.init();
  await IncomeRepository.instance.init();

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cashly',
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
