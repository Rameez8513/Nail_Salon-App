import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/product_model.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class ProductListTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onEdit,
  });

  Color get _statusColor {
    switch (product.status) {
      case StockStatus.inStock:
        return AppColors.success;
      case StockStatus.lowStock:
        return AppColors.warning;
      case StockStatus.outOfStock:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (product.status) {
      case StockStatus.inStock:
        return AppStrings.t('inStock');
      case StockStatus.lowStock:
        return AppStrings.t('lowStock');
      case StockStatus.outOfStock:
        return AppStrings.t('outOfStock');
    }
  }

  void _adjustStock(int delta) {
    final newStock = (product.currentStock + delta).clamp(0, 999999);
    FirestoreService.instance.updateProduct(product.id, {
      'currentStock': newStock,
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onEdit,
          splashColor: AppColors.primary.withOpacity(0.08),
          highlightColor: AppColors.primary.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.content_cut_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel,
                              style: TextStyle(
                                color: _statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat(
                        'MM/dd/yyyy h:mm a',
                        AppStrings.currentLanguage,
                      ).format(product.updatedAt),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textGrey,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StepperButton(
                            icon: Icons.remove,
                            onTap: () => _adjustStock(-1),
                          ),
                          Container(
                            width: 36,
                            alignment: Alignment.center,
                            child: Text(
                              '${product.currentStock}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          _StepperButton(
                            icon: Icons.add,
                            onTap: () => _adjustStock(1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
      ),
    );
  }
}
