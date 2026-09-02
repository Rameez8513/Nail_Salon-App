import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/routes/slide_up_route.dart';
import '../../../models/service_model.dart';
import '../widgets/service_list_tile.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddService() {
    Navigator.of(context).push(SlideUpRoute(page: const AddServiceScreen()));
  }

  void _openEditService(ServiceModel service) {
    Navigator.of(
      context,
    ).push(SlideUpRoute(page: EditServiceScreen(service: service)));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.t('services'),
        actionIcon: Icons.add,
        onActionPressed: _openAddService,
      ),
      body: Column(
        children: [
          SearchField(
            controller: _searchController,
            hint: AppStrings.t('searchService'),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.instance.servicesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final services = docs
                    .map(
                      (doc) => ServiceModel.fromMap(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .where(
                      (s) => s.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                if (services.isEmpty) {
                  return EmptyState(
                    icon: Icons.back_hand_outlined,
                    title: AppStrings.t('noServiceFound'),
                    subtitle: AppStrings.t('addFirstService'),
                    buttonLabel: AppStrings.t('addService'),
                    onPressed: _openAddService,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return FadeSlideIn(
                      index: index,
                      child: ServiceListTile(
                        service: service,
                        onEdit: () => _openEditService(service),
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
