import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/routes/slide_up_route.dart';
import '../../../models/employee_model.dart';
import '../widgets/employee_list_tile.dart';
import 'add_employee_screen.dart';
import 'edit_employee_screen.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddEmployee() {
    Navigator.of(context).push(SlideUpRoute(page: const AddEmployeeScreen()));
  }

  void _openEditEmployee(EmployeeModel employee) {
    Navigator.of(
      context,
    ).push(SlideUpRoute(page: EditEmployeeScreen(employee: employee)));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.t('employees'),
        actionIcon: Icons.person_add_alt_1_outlined,
        onActionPressed: _openAddEmployee,
      ),
      body: Column(
        children: [
          SearchField(
            controller: _searchController,
            hint: AppStrings.t('searchEmployee'),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.instance.employeesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final employees = docs
                    .map(
                      (d) => EmployeeModel.fromMap(
                        d.id,
                        d.data() as Map<String, dynamic>,
                      ),
                    )
                    .where(
                      (e) => e.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                if (employees.isEmpty) {
                  return EmptyState(
                    icon: Icons.badge_outlined,
                    title: AppStrings.t('noEmployeesYet'),
                    subtitle: AppStrings.t('addFirstEmployee'),
                    buttonLabel: AppStrings.t('addEmployee'),
                    onPressed: _openAddEmployee,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return FadeSlideIn(
                      index: index,
                      child: EmployeeListTile(
                        employee: employee,
                        onEdit: () => _openEditEmployee(employee),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
