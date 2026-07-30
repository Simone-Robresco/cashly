import 'package:flutter/material.dart';
import '../models/income_model.dart';
import '../local/local_storage.dart';

class IncomeRepository extends ChangeNotifier {
  IncomeRepository._internal();
  static final IncomeRepository instance = IncomeRepository._internal();

  static const _storageKey = 'incomes';

  final List<IncomeModel> _incomes = [];
  bool _initialized = false;

  List<IncomeModel> get incomes => List.unmodifiable(_incomes);

  Future<void> init() async {
    if (_initialized) return;
    await LocalStorage.ensureReady();
    final saved = LocalStorage.loadList(_storageKey);
    _incomes
      ..clear()
      ..addAll(saved.map(IncomeModel.fromMap));
    _initialized = true;
    notifyListeners();
  }

  void addIncome(IncomeModel income) {
    _incomes.add(income);
    _persist();
    notifyListeners();
  }

  void updateIncome(IncomeModel updated) {
    final index = _incomes.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    _incomes[index] = updated;
    _persist();
    notifyListeners();
  }

  void deleteIncome(String id) {
    _incomes.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  void _persist() {
    LocalStorage.saveList(_storageKey, _incomes.map((e) => e.toMap()).toList());
  }
}
