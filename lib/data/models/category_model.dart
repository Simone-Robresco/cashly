import 'package:flutter/material.dart';

enum CategoryType { expense, income }

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final CategoryType type;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type = CategoryType.expense,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'color': color.value,
        'type': type == CategoryType.income ? 'income' : 'expense',
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    // ignore: non_const_argument_for_const_parameter
    final icon = IconData(
      map['iconCodePoint'] as int,
      fontFamily: map['iconFontFamily'] as String?,
    );
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: icon,
      color: Color(map['color'] as int),
      // le categorie salvate prima di questa modifica non hanno 'type':
      // di default restano categorie spesa, comportamento invariato.
      type: map['type'] == 'income' ? CategoryType.income : CategoryType.expense,
    );
  }
}
