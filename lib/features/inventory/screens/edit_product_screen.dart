import 'package:flutter/material.dart';
import 'package:nail_salon/core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../models/product_model.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _currentStockController;
  late final TextEditingController _minimumStockController;
  late final TextEditingController _priceController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _currentStockController = TextEditingController(
      text: widget.product.currentStock.toString(),
    );
    _minimumStockController = TextEditingController(
      text: widget.product.minimumStock.toString(),
    );
    _priceController = TextEditingController(
      text: widget.product.price?.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.product.notes ?? '');
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

  void _updateProduct() {
    if (!_formKey.currentState!.validate()) return;

    FirestoreService.instance.updateProduct(widget.product.id, {
      'name': _nameController.text.trim(),
      'currentStock': int.tryParse(_currentStockController.text.trim()) ?? 0,
      'minimumStock': int.tryParse(_minimumStockController.text.trim()) ?? 0,
      'price': double.tryParse(_priceController.text.trim()),
      'notes': _notesController.text.trim(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('productUpdated'));
  }

  Future<void> _deleteProduct() async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      itemName: widget.product.name,
    );
    if (!confirmed) return;

    FirestoreService.instance.deleteProduct(widget.product.id);

    if (!mounted) return;
    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('productDeleted'));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t('editProduct')),
        actions: [
          IconButton(
            onPressed: _deleteProduct,
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          TextButton.icon(
            onPressed: _updateProduct,
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
                hint: 'Ex: Gel Polish - Red',
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
                hint: AppStrings.t('notesOptional'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _updateProduct,
                child: Text(AppStrings.t('save')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _deleteProduct,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(AppStrings.t('deleteProduct')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
