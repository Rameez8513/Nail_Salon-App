import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1400),
        elevation: 4,
      ),
    );
  }
}
