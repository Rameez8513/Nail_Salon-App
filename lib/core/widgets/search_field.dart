import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class SearchField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textGrey,
            size: 22,
          ),
        ),
      ),
    );
  }
}
