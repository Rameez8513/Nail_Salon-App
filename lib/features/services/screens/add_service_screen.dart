import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  void _saveService() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String();
    final data = {
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'durationMinutes': int.tryParse(_durationController.text.trim()) ?? 0,
      'notes': _notesController.text.trim(),
      'createdAt': now,
      'updatedAt': now,
    };

    FirestoreService.instance.addService(data);

    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('serviceAdded'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t('addService')),
        actions: [
          TextButton.icon(
            onPressed: _saveService,
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
                onPressed: _saveService,
                child: Text(AppStrings.t('addService')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
