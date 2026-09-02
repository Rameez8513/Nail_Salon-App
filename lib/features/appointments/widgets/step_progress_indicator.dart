import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (index) {
          if (index.isOdd) {
            final lineStep = index ~/ 2;
            final isDone = currentStep > lineStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isDone ? AppColors.primary : AppColors.border,
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isDone = currentStep > stepIndex;
          final isCurrent = currentStep == stepIndex;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (isDone || isCurrent)
                      ? AppColors.primary
                      : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isDone || isCurrent)
                        ? AppColors.primary
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          color: isCurrent ? Colors.white : AppColors.textGrey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: (isDone || isCurrent)
                      ? AppColors.primary
                      : AppColors.textGrey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
