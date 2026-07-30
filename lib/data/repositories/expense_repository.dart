import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../local/local_storage.dart';

/// Tiene in memoria la lista delle spese, la salva in permanenza sul
/// telefono e avvisa chi la usa quando cambia (creazione, modifica,
/// eliminazione). All'installazione parte vuota.
class ExpenseRepository extends ChangeNotifier {
  ExpenseRepository._internal();
  static final ExpenseRepository instance = ExpenseRepository._internal();

  static const _storageKey = 'expenses';

  final List<ExpenseModel> _expenses = [];
  bool _initialized = false;

  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);

  /// Da chiamare una volta all'avvio dell'app (in main.dart), prima di
  /// runApp: carica le spese salvate in precedenza.
  Future<void> init() async {
    if (_initialized) return;
    await LocalStorage.ensureReady();
    final saved = LocalStorage.loadList(_storageKey);
    _expenses
      ..clear()
      ..addAll(saved.map(ExpenseModel.fromMap));
    _initialized = true;
    notifyListeners();
  }

  void addExpense(ExpenseModel expense) {
    _expenses.add(expense);
    _persist();
    notifyListeners();
  }

  void updateExpense(ExpenseModel updated) {
    final index = _expenses.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;
    _expenses[index] = updated;
    _persist();
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  void _persist() {
    LocalStorage.saveList(_storageKey, _expenses.map((e) => e.toMap()).toList());
  }
}
