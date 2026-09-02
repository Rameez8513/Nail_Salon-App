import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/routes/slide_up_route.dart';
import '../../../models/client_model.dart';
import '../../Customers/screens/add_client_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class SelectClientSheet extends StatelessWidget {
  const SelectClientSheet({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance.clientsStream(),
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
        final clients = docs
            .map(
              (d) =>
                  ClientModel.fromMap(d.id, d.data() as Map<String, dynamic>),
            )
            .toList();

        if (clients.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 48,
                  color: AppColors.textGrey,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.t('noClientsAddedYet'),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.t('addClientFirstToBook'),
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).push(SlideUpRoute(page: const AddClientScreen()));
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(AppStrings.t('addClient')),
                ),
              ],
            ),
          );
        }

        return Column(
          children: clients.map((client) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(
                client.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: client.phone != null && client.phone!.isNotEmpty
                  ? Text(client.phone!)
                  : null,
              onTap: () => Navigator.of(context).pop(client),
            );
          }).toList(),
        );
      },
    );
  }
}
