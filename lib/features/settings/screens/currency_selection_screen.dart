import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/constants/app_strings.dart';

class CurrencySelectionScreen extends StatelessWidget {
  const CurrencySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t('currencys'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: AppSettingsProvider.currencies.length,
        itemBuilder: (context, index) {
          final currency = AppSettingsProvider.currencies[index];
          final isSelected = settings.currencyCode == currency.code;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 1.6)
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  context.read<AppSettingsProvider>().setCurrency(
                    currency.code,
                  );
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(currency.flag, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currency.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${currency.code} · ${currency.symbol}',
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
