import 'package:flutter/material.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/models/category_model.dart';
import '../../core/constants/app_colors.dart';
import '../category_create/create_category_page.dart';

class CategoriesManagePage extends StatelessWidget {
  const CategoriesManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateCategoryPage()),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([CategoryRepository.instance, ExpenseRepository.instance]),
        builder: (context, _) {
          final categories = CategoryRepository.instance.categories;
          final expenses = ExpenseRepository.instance.expenses;

          if (categories.isEmpty) {
            return const Center(
              child: Text('Nessuna categoria', style: TextStyle(color: AppColors.textSecondary)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final category = categories[index];
              final count = expenses.where((e) => e.categoryId == category.id).length;
              return _CategoryRow(category: category, expenseCount: count);
            },
          );
        },
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryModel category;
  final int expenseCount;

  const _CategoryRow({required this.category, required this.expenseCount});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CreateCategoryPage(existingCategory: category)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: category.color.withValues(alpha: 0.22),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              Text(
                expenseCount == 1 ? '1 spesa' : '$expenseCount spese',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
