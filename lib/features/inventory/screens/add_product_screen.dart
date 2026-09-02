import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String();
    final data = {
      'name': _nameController.text.trim(),
      'currentStock': int.tryParse(_currentStockController.text.trim()) ?? 0,
      'minimumStock': int.tryParse(_minimumStockController.text.trim()) ?? 0,
      'price': double.tryParse(_priceController.text.trim()),
      'notes': _notesController.text.trim(),
      'createdAt': now,
      'updatedAt': now,
    };

    FirestoreService.instance.addProduct(data);

    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('productAdded'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentStockController.dispose();
    _minimumStockController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t('addProduct')),
        actions: [
          TextButton.icon(
            onPressed: _saveProduct,
            icon: const Icon(
              Icons.save_outlined,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              AppStrings.t('save'),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: AppStrings.t('name'),
                controller: _nameController,
                hint: 'Ex: Gel Polish',
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.t('nameRequired')
                    : null,
              ),
              CustomTextField(
                label: AppStrings.t('currentStock'),
                controller: _currentStockController,
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.t('currentStockRequired')
                    : null,
              ),
              CustomTextField(
                label: AppStrings.t('minimumStock'),
                controller: _minimumStockController,
                hint: '5',
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.t('minimumStockRequired')
                    : null,
              ),
              CustomTextField(
                label: AppStrings.t('priceOptional'),
                controller: _priceController,
                hint: '\0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              CustomTextField(
                label: AppStrings.t('notesOptional'),
                controller: _notesController,
                hint: AppStrings.t('notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(AppStrings.t('addProduct')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
