import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();

  void _saveEmployee() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': _roleController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    FirestoreService.instance.addEmployee(data);

    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('employeeAdded'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t('addEmployee')),
        actions: [
          TextButton.icon(
            onPressed: _saveEmployee,
            icon: const Icon(
              Icons.save_outlined,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              AppStrings.t('save'),
              style: const TextStyle(color: Colors.white),
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
                label: AppStrings.t('roleOptional'),
                controller: _roleController,
                hint: AppStrings.t('exampleRoleHint'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saveEmployee,
                child: Text(AppStrings.t('addEmployee')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
