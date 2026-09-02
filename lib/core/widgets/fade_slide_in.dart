import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class FadeSlideIn extends StatelessWidget {
  final int index;
  final Widget child;

  const FadeSlideIn({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 280 + (index * 40).clamp(0, 240)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
