import 'category_model.dart';
import '../repositories/category_repository.dart';

/// Singola spesa registrata dall'utente.
///
/// Salva solo [categoryId], non l'intera categoria: così se in futuro
/// modifichi nome/icona/colore di una categoria, tutte le spese passate
/// che la usano si aggiornano da sole (non restano con i dati vecchi).
class ExpenseModel {
  final String id;
  final String productName;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String? description;

  const ExpenseModel({
    required this.id,
    required this.productName,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.description,
  });

  /// Categoria attuale (letta ogni volta dal repository).
  CategoryModel get category => CategoryRepository.instance.categoryById(categoryId);

  Map<String, dynamic> toMap() => {
        'id': id,
        'productName': productName,
        'categoryId': categoryId,
        'amount': amount,
        'date': date.toIso8601String(),
        'description': description,
      };

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
        id: map['id'] as String,
        productName: map['productName'] as String,
        categoryId: map['categoryId'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        description: map['description'] as String?,
      );
}
