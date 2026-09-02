import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../models/service_model.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class EditServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _priceController = TextEditingController(
      text: widget.service.price.toString(),
    );
    _durationController = TextEditingController(
      text: widget.service.durationMinutes.toString(),
    );
    _notesController = TextEditingController(text: widget.service.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateService() {
    if (!_formKey.currentState!.validate()) return;

    FirestoreService.instance.updateService(widget.service.id, {
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'durationMinutes': int.tryParse(_durationController.text.trim()) ?? 0,
      'notes': _notesController.text.trim(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('serviceUpdated'));
  }

  Future<void> _deleteService() async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      itemName: widget.service.name,
    );
    if (!confirmed) return;

    FirestoreService.instance.deleteService(widget.service.id);

    if (!mounted) return;
    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('serviceDeleted'));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t('editService')),
        actions: [
          IconButton(
            onPressed: _deleteService,
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          TextButton.icon(
            onPressed: _updateService,
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
                hint: AppStrings.t('exampleServiceNameHint'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.t('nameRequired')
                    : null,
              ),
              CustomTextField(
                label: AppStrings.t('price'),
                controller: _priceController,
                hint: AppStrings.t('examplePriceHint'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.t('priceRequired')
                    : null,
              ),
              CustomTextField(
                label: AppStrings.t('duration'),
                controller: _durationController,
                hint: AppStrings.t('exampleDurationHint'),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.t('durationRequired')
                    : null,
              ),
              CustomTextField(
                label: AppStrings.t('notesOptional'),
                controller: _notesController,
                hint: AppStrings.t('notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _updateService,
                child: Text(AppStrings.t('saveChanges')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _deleteService,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(AppStrings.t('deleteService')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
