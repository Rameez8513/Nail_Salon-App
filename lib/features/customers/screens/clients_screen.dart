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
import '../../../models/client_model.dart';
import '../widgets/client_list_tile.dart';
import 'add_client_screen.dart';
import 'edit_client_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddClient() {
    Navigator.of(context).push(SlideUpRoute(page: const AddClientScreen()));
  }

  void _openEditClient(ClientModel client) {
    Navigator.of(
      context,
    ).push(SlideUpRoute(page: EditClientScreen(client: client)));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.t('clients'),
        actionIcon: Icons.person_add_alt_1_outlined,
        onActionPressed: _openAddClient,
      ),
      body: Column(
        children: [
          SearchField(
            controller: _searchController,
            hint: AppStrings.t('searchClient'),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.instance.clientsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final clients = docs
                    .map(
                      (doc) => ClientModel.fromMap(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .where(
                      (c) => c.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                if (clients.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: AppStrings.t('noClientsYet'),
                    subtitle: AppStrings.t('addFirstClient'),
                    buttonLabel: AppStrings.t('addClient'),
                    onPressed: _openAddClient,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return FadeSlideIn(
                      index: index,
                      child: ClientListTile(
                        client: client,
                        onEdit: () => _openEditClient(client),
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
