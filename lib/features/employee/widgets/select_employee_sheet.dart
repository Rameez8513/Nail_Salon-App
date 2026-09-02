import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/routes/slide_up_route.dart';
import '../../../models/employee_model.dart';
import '../../employee/screens/add_employee_screen.dart';

class SelectEmployeeSheet extends StatelessWidget {
  const SelectEmployeeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance.employeesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final employeesList = docs
            .map(
              (d) =>
                  EmployeeModel.fromMap(d.id, d.data() as Map<String, dynamic>),
            )
            .toList();

        if (employeesList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 48,
                  color: AppColors.textGrey,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.t('noEmployeesAddedYet'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.t('addEmployeeFirstToBook'),
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).push(SlideUpRoute(page: const AddEmployeeScreen()));
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(AppStrings.t('addEmployee')),
                ),
              ],
            ),
          );
        }

        return Column(
          children: employeesList.map((employee) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(
                employee.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: employee.role != null && employee.role!.isNotEmpty
                  ? Text(employee.role!)
                  : null,
              onTap: () => Navigator.of(context).pop(employee),
            );
          }).toList(),
        );
      },
    );
  }
}
