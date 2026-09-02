import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/appointment_model.dart';
import '../widgets/appointment_card.dart';
import 'appointment_detail_screen.dart';
import '../../../core/constants/app_strings.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';

class MonthAppointmentsScreen extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final String monthLabel;

  const MonthAppointmentsScreen({
    super.key,
    required this.appointments,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(monthLabel)),
      body: appointments.isEmpty
          ? EmptyState(
              icon: Icons.calendar_today_outlined,
              title: AppStrings.t('noAppointments'),
              subtitle: '${AppStrings.t('nothingBookedIn')} $monthLabel',
              buttonLabel: AppStrings.t('back'),
              onPressed: () => Navigator.of(context).pop(),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: appointments.length,
              itemBuilder: (context, index) => AppointmentCard(
                appointment: appointments[index],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AppointmentDetailScreen(
                      appointment: appointments[index],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
