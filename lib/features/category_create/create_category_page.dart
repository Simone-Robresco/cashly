import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/category_colors.dart';
import '../../core/utils/color_shades.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/accent_button.dart';

class CreateCategoryPage extends StatefulWidget {
  final CategoryModel? existingCategory;
  /// Usato solo in creazione (non in modifica): a quale tipo appartiene
  /// la nuova categoria.
  final CategoryType categoryType;

  const CreateCategoryPage({
    super.key,
    this.existingCategory,
    this.categoryType = CategoryType.expense,
  });

  bool get isEditing => existingCategory != null;

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  late final _nameController = TextEditingController(text: widget.existingCategory?.name ?? '');
  IconData? _selectedIcon;
  Color? _selectedColor;

  static const List<IconData> _icons = [
    Icons.shopping_cart_outlined,
    Icons.directions_bus_filled_outlined,
    Icons.local_movies_outlined,
    Icons.receipt_long_outlined,
    Icons.restaurant_outlined,
    Icons.home_outlined,
    Icons.medical_services_outlined,
    Icons.fitness_center_outlined,
    Icons.pets_outlined,
    Icons.flight_outlined,
    Icons.school_outlined,
    Icons.sports_esports_outlined,
    Icons.card_giftcard_outlined,
    Icons.local_gas_station_outlined,
    Icons.coffee_outlined,
    Icons.checkroom_outlined,
    Icons.build_outlined,
    Icons.spa_outlined,
    Icons.smartphone_outlined,
    Icons.subscriptions_outlined,
    Icons.work_outline_rounded,
    Icons.savings_outlined,
    Icons.trending_up_rounded,
    Icons.attach_money_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.existingCategory?.icon;
    _selectedColor = widget.existingCategory?.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Modifica categoria' : 'Nuova categoria'),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: _onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _fieldDecoration('Nome categoria'),
          ),
          const SizedBox(height: 28),
          Text('Icona', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildIconGrid(),
          const SizedBox(height: 28),
          Text('Colore', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildColorPicker(),
          const SizedBox(height: 32),
          AccentButton(
            label: widget.isEditing ? 'Salva modifiche' : 'Crea categoria',
            onPressed: _onSave,
          ),
        ],
      ),
    );
  }

  Widget _buildIconGrid() {
    final previewColor = _selectedColor ?? AppColors.accent;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _icons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final icon = _icons[index];
        final selected = icon == _selectedIcon;
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _selectedIcon = icon),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? previewColor.withValues(alpha: 0.18) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? previewColor : AppColors.divider, width: selected ? 2 : 1),
            ),
            child: Icon(icon, color: selected ? previewColor : AppColors.textSecondary),
          ),
        );
      },
    );
  }

  Widget _buildColorPicker() {
    return Column(
      children: categoryBaseHues.map((hue) {
        final shades = colorShades(hue);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: shades.map((shade) {
              final selected = shade == _selectedColor;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _selectedColor = shade),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: shade,
                        shape: BoxShape.circle,
                        border: selected ? Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2.5) : null,
                      ),
                      child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppNotice(context, 'Inserisci un nome per la categoria');
      return;
    }
    if (_selectedIcon == null) {
      showAppNotice(context, 'Scegli un\'icona');
      return;
    }
    if (_selectedColor == null) {
      showAppNotice(context, 'Scegli un colore');
      return;
    }

    if (widget.isEditing) {
      final updated = CategoryModel(
        id: widget.existingCategory!.id,
        name: name,
        icon: _selectedIcon!,
        color: _selectedColor!,
        type: widget.existingCategory!.type,
      );
      CategoryRepository.instance.updateCategory(updated);
      Navigator.of(context).pop(updated);
    } else {
      final newCategory = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        icon: _selectedIcon!,
        color: _selectedColor!,
        type: widget.categoryType,
      );
      CategoryRepository.instance.addCategory(newCategory);
      Navigator.of(context).pop(newCategory);
    }
  }

  void _onDelete() {
    final category = widget.existingCategory!;
    final inUseExpense = ExpenseRepository.instance.expenses.any((e) => e.categoryId == category.id);
    final inUseIncome = IncomeRepository.instance.incomes.any((e) => e.categoryId == category.id);
    if (inUseExpense || inUseIncome) {
      showAppNotice(context, 'Categoria usata da alcune voci: non puoi eliminarla');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminare categoria?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('La categoria "${category.name}" verrà eliminata definitivamente.', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Annulla', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              CategoryRepository.instance.deleteCategory(category.id);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Elimina', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
