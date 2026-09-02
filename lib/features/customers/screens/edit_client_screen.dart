import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../models/client_model.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class EditClientScreen extends StatefulWidget {
  final ClientModel client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client.name);
    _phoneController = TextEditingController(text: widget.client.phone ?? '');
    _notesController = TextEditingController(text: widget.client.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateClient() {
    if (!_formKey.currentState!.validate()) return;

    FirestoreService.instance.updateClient(widget.client.id, {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'notes': _notesController.text.trim(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('clientUpdated'));
  }

  Future<void> _deleteClient() async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      itemName: widget.client.name,
    );
    if (!confirmed) return;

    FirestoreService.instance.deleteClient(widget.client.id);

    if (!mounted) return;
    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('clientDeleted'));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t('editClient')),
        actions: [
          IconButton(
            onPressed: _deleteClient,
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          TextButton.icon(
            onPressed: _updateClient,
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
                hint: AppStrings.t('exampleNameHint'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? AppStrings.t('nameRequired')
                    : null,
              ),
              CustomTextField(
                label: AppStrings.t('phoneOptional'),
                controller: _phoneController,
                hint: AppStrings.t('examplePhoneHint'),
                keyboardType: TextInputType.phone,
              ),
              CustomTextField(
                label: AppStrings.t('notesOptional'),
                controller: _notesController,
                hint: AppStrings.t('notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _updateClient,
                child: Text(AppStrings.t('saveChanges')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _deleteClient,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(AppStrings.t('deleteClient')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
