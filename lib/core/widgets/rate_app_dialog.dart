import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'app_snackbar.dart';

class RateAppDialog {
  RateAppDialog._();

  static void show(BuildContext context) {
    int selectedStars = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      AppStrings.t('rateThisApp'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.t('rateThisAppDesc'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedStars = starIndex),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 150),
                            scale: selectedStars >= starIndex ? 1.15 : 1.0,
                            child: Icon(
                              selectedStars >= starIndex
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: selectedStars >= starIndex
                                  ? Colors.amber
                                  : AppColors.border,
                              size: 34,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: selectedStars == 0
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              AppSnackbar.show(
                                context,
                                AppStrings.t('thanksForRating'),
                              );
                            },
                      child: Text(AppStrings.t('submit')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
