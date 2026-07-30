import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../local/local_storage.dart';

const CategoryModel _deletedPlaceholder = CategoryModel(
  id: '_deleted',
  name: 'Categoria eliminata',
  icon: Icons.help_outline_rounded,
  color: Color(0xFF6B6B76),
);

class CategoryRepository extends ChangeNotifier {
  CategoryRepository._internal();
  static final CategoryRepository instance = CategoryRepository._internal();

  static const _storageKey = 'categories';

  final List<CategoryModel> _categories = [];
  bool _initialized = false;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == CategoryType.expense).toList();
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == CategoryType.income).toList();

  Future<void> init() async {
    if (_initialized) return;
    await LocalStorage.ensureReady();
    final saved = LocalStorage.loadList(_storageKey);
    _categories
      ..clear()
      ..addAll(saved.map(CategoryModel.fromMap));
    _initialized = true;
    notifyListeners();
  }

  CategoryModel categoryById(String id) {
    return _categories.firstWhere((c) => c.id == id, orElse: () => _deletedPlaceholder);
  }

  void addCategory(CategoryModel category) {
    _categories.add(category);
    _persist();
    notifyListeners();
  }

  void updateCategory(CategoryModel updated) {
    final index = _categories.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    _categories[index] = updated;
    _persist();
    notifyListeners();
  }

  bool deleteCategory(String id) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return false;
    _categories.removeAt(index);
    _persist();
    notifyListeners();
    return true;
  }

  void _persist() {
    LocalStorage.saveList(_storageKey, _categories.map((c) => c.toMap()).toList());
  }
}
