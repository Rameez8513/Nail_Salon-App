import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/routes/slide_up_route.dart';
import '../../../models/service_model.dart';
import '../../services/screens/add_service_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class SelectServicesSheet extends StatefulWidget {
  final List<String> alreadySelectedIds;

  const SelectServicesSheet({super.key, required this.alreadySelectedIds});

  @override
  State<SelectServicesSheet> createState() => _SelectServicesSheetState();
}

class _SelectServicesSheetState extends State<SelectServicesSheet> {
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.alreadySelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance.servicesStream(),
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
        final allServices = docs
            .map(
              (d) =>
                  ServiceModel.fromMap(d.id, d.data() as Map<String, dynamic>),
            )
            .toList();

        if (allServices.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.back_hand_outlined,
                  size: 48,
                  color: AppColors.textGrey,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.t('noServicesAddedYet'),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.t('addServiceFirstToBook'),
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).push(SlideUpRoute(page: const AddServiceScreen()));
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(AppStrings.t('addService')),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            ...allServices.map((service) {
              final isSelected = _selectedIds.contains(service.id);
              return CheckboxListTile(
                value: isSelected,
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedIds.add(service.id);
                    } else {
                      _selectedIds.remove(service.id);
                    }
                  });
                },
                title: Text(
                  service.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${service.durationMinutes} min · \$${service.price.toStringAsFixed(2)}',
                ),
              );
            }),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  final selected = allServices
                      .where((s) => _selectedIds.contains(s.id))
                      .toList();
                  Navigator.of(context).pop(selected);
                },
                child: Text(
                  '${AppStrings.t('addLabel')} ${_selectedIds.length} ${_selectedIds.length == 1 ? AppStrings.t('serviceSingular') : AppStrings.t('services')}',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
