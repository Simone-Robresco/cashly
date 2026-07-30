import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../constants/app_colors.dart';

class CategoryDropdown extends StatelessWidget {
  static const _addSentinel = '__add_category__';

  final List<CategoryModel> categories;
  final CategoryModel? selected;
  final ValueChanged<CategoryModel> onSelected;
  final VoidCallback onAddCategory;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selected?.id,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: 'Categoria',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      items: [
        ...categories.map(
          (category) => DropdownMenuItem<String>(
            value: category.id,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: category.color.withValues(alpha: 0.15),
                  child: Icon(category.icon, size: 15, color: category.color),
                ),
                const SizedBox(width: 10),
                Text(category.name),
              ],
            ),
          ),
        ),
        const DropdownMenuItem<String>(
          value: _addSentinel,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, color: AppColors.accent, size: 20),
              SizedBox(width: 10),
              Text('Aggiungi categoria', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        if (value == _addSentinel) {
          onAddCategory();
          return;
        }
        final match = categories.where((c) => c.id == value);
        if (match.isNotEmpty) onSelected(match.first);
      },
      validator: (value) => value == null ? 'Seleziona una categoria' : null,
    );
  }
}
