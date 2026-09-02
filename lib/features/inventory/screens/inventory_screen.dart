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
import '../../../models/product_model.dart';
import '../widgets/product_list_tile.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddProduct() {
    Navigator.of(context).push(SlideUpRoute(page: const AddProductScreen()));
  }

  void _openEditProduct(ProductModel product) {
    Navigator.of(
      context,
    ).push(SlideUpRoute(page: EditProductScreen(product: product)));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    context.watch<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.t('inventory'),
        actionIcon: Icons.add,
        onActionPressed: _openAddProduct,
      ),
      body: Column(
        children: [
          SearchField(
            controller: _searchController,
            hint: AppStrings.t('searchProduct'),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.instance.inventoryStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final products = docs
                    .map(
                      (doc) => ProductModel.fromMap(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .where(
                      (p) => p.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

                if (products.isEmpty) {
                  return EmptyState(
                    icon: Icons.content_cut_outlined,
                    title: AppStrings.t('noProductsFound'),
                    subtitle: AppStrings.t('addProductsToStart'),
                    buttonLabel: AppStrings.t('addProduct'),
                    onPressed: _openAddProduct,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return FadeSlideIn(
                      index: index,
                      child: ProductListTile(
                        product: product,
                        onEdit: () => _openEditProduct(product),
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
