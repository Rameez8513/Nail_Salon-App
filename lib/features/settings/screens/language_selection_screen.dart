import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/widgets/app_snackbar.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t('language'))),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: AppSettingsProvider.languages.length,
        itemBuilder: (context, index) {
          final language = AppSettingsProvider.languages[index];
          final isSelected = settings.languageCode == language.code;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
                onTap: () async {
                  await context.read<AppSettingsProvider>().setLanguage(
                    language.code,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  AppSnackbar.show(context, '${language.name} selected');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(language.flag, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          language.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                key: ValueKey('checked'),
                              )
                            : const SizedBox(
                                width: 24,
                                key: ValueKey('unchecked'),
                              ),
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
