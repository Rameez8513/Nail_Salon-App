import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../models/appointment_model.dart';
import '../../../core/constants/app_strings.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    final symbol = context.watch<AppSettingsProvider>().currencySymbol;
    final serviceNames = appointment.services.map((s) => s.name).join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('h:mm a', AppStrings.currentLanguage).format(appointment.startTime)} - ${DateFormat('h:mm a', AppStrings.currentLanguage).format(appointment.endTime)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appointment.clientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    serviceNames,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '$symbol${appointment.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
