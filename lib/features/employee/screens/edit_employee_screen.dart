import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../models/employee_model.dart';

class EditEmployeeScreen extends StatefulWidget {
  final EmployeeModel employee;

  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee.name);
    _phoneController = TextEditingController(text: widget.employee.phone ?? '');
    _roleController = TextEditingController(text: widget.employee.role ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _updateEmployee() {
    if (!_formKey.currentState!.validate()) return;

    FirestoreService.instance.updateEmployee(widget.employee.id, {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': _roleController.text.trim(),
    });

    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('employeeUpdated'));
  }

  Future<void> _deleteEmployee() async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      itemName: widget.employee.name,
    );
    if (!confirmed) return;

    FirestoreService.instance.deleteEmployee(widget.employee.id);

    if (!mounted) return;
    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('employeeDeleted'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t('editEmployee')),
        actions: [
          IconButton(
            onPressed: _deleteEmployee,
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          TextButton.icon(
            onPressed: _updateEmployee,
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
                onPressed: _updateEmployee,
                child: Text(AppStrings.t('saveChanges')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _deleteEmployee,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(AppStrings.t('deleteEmployee')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
