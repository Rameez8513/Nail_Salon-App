import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  void _saveClient() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String();
    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'notes': _notesController.text.trim(),
      'createdAt': now,
      'updatedAt': now,
    };

    FirestoreService.instance.addClient(data);

    Navigator.of(context).pop();
    AppSnackbar.show(context, 'Client added');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t('addClient')),
        actions: [
          TextButton.icon(
            onPressed: _saveClient,
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
                hint: 'Ex: Carol',
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.t('nameRequired')
                    : null,
              ),
              CustomTextField(
                label: AppStrings.t('phoneOptional'),
                controller: _phoneController,
                hint: '+100 000 000 000',
                keyboardType: TextInputType.phone,
              ),
              CustomTextField(
                label: AppStrings.t('notesOptional'),
                controller: _notesController,
                hint: AppStrings.t('notesOptional'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveClient,
                child: Text(AppStrings.t('addClient')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
