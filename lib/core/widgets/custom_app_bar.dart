import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actionIcon,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return AppBar(
      title: Text(title),
      actions: actionIcon != null
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Icon(actionIcon, color: Colors.white),
                  onPressed: onActionPressed,
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
