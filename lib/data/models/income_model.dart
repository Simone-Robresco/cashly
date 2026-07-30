import 'category_model.dart';
import '../repositories/category_repository.dart';

class IncomeModel {
  final String id;
  final String productName;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String? description;

  const IncomeModel({
    required this.id,
    required this.productName,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.description,
  });

  CategoryModel get category => CategoryRepository.instance.categoryById(categoryId);

  Map<String, dynamic> toMap() => {
        'id': id,
        'productName': productName,
        'categoryId': categoryId,
        'amount': amount,
        'date': date.toIso8601String(),
        'description': description,
      };

  factory IncomeModel.fromMap(Map<String, dynamic> map) => IncomeModel(
        id: map['id'] as String,
        productName: map['productName'] as String,
        categoryId: map['categoryId'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        description: map['description'] as String?,
      );
}
