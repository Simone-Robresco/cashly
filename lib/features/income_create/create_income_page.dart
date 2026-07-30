import 'package:flutter/material.dart';
import '../../data/models/income_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/income_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/accent_button.dart';
import '../../core/widgets/category_dropdown.dart';
import '../category_create/create_category_page.dart';

const String _euro = '\u20AC';

class CreateIncomePage extends StatefulWidget {
  final IncomeModel? existingIncome;

  const CreateIncomePage({super.key, this.existingIncome});

  bool get isEditing => existingIncome != null;

  @override
  State<CreateIncomePage> createState() => _CreateIncomePageState();
}

class _CreateIncomePageState extends State<CreateIncomePage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.existingIncome?.productName ?? '');
  late final _priceController = TextEditingController(
    text: widget.existingIncome != null ? widget.existingIncome!.amount.toStringAsFixed(2) : '',
  );
  late final _descriptionController = TextEditingController(text: widget.existingIncome?.description ?? '');

  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.existingIncome != null) {
      _selectedCategory = CategoryRepository.instance.categoryById(widget.existingIncome!.categoryId);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Modifica entrata' : 'Nuova entrata')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _fieldDecoration('Nome entrata'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Inserisci il nome dell\'entrata' : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _priceController,
              style: const TextStyle(color: AppColors.textPrimary),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _fieldDecoration('Importo ($_euro)'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Inserisci l\'importo';
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) return 'Importo non valido';
                return null;
              },
            ),
            const SizedBox(height: 18),
            AnimatedBuilder(
              animation: CategoryRepository.instance,
              builder: (context, _) {
                return CategoryDropdown(
                  categories: CategoryRepository.instance.incomeCategories,
                  selected: _selectedCategory,
                  onSelected: (category) => setState(() => _selectedCategory = category),
                  onAddCategory: _openCreateCategory,
                );
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 4,
              decoration: _fieldDecoration('Descrizione (facoltativa)'),
            ),
            const SizedBox(height: 32),
            AccentButton(label: widget.isEditing ? 'Salva modifiche' : 'Salva entrata', onPressed: _onSave),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: AppColors.accent, width: 2)),
    );
  }

  Future<void> _openCreateCategory() async {
    final result = await Navigator.of(context).push<CategoryModel>(
      MaterialPageRoute(builder: (_) => const CreateCategoryPage(categoryType: CategoryType.income)),
    );
    if (result != null) setState(() => _selectedCategory = result);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      showAppNotice(context, 'Seleziona una categoria');
      return;
    }

    final amount = double.parse(_priceController.text.trim().replaceAll(',', '.'));
    final description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();

    if (widget.isEditing) {
      IncomeRepository.instance.updateIncome(IncomeModel(
        id: widget.existingIncome!.id,
        productName: _nameController.text.trim(),
        categoryId: _selectedCategory!.id,
        amount: amount,
        date: widget.existingIncome!.date,
        description: description,
      ));
    } else {
      IncomeRepository.instance.addIncome(IncomeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: _nameController.text.trim(),
        categoryId: _selectedCategory!.id,
        amount: amount,
        date: DateTime.now(),
        description: description,
      ));
    }
    Navigator.of(context).pop();
  }
}
