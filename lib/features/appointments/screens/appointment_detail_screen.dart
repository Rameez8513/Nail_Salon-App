import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/widgets/confirm_delete_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../models/appointment_model.dart';
import 'new_appointment_screen.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  void _editAppointment(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => NewAppointmentScreen(
          initialDate: appointment.startTime,
          existingAppointment: appointment,
        ),
      ),
    );
  }

  Future<void> _cancelAppointment(BuildContext context) async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      itemName: AppStrings.t('deleteAppointment'),
    );
    if (!confirmed) return;

    FirestoreService.instance.deleteAppointment(appointment.id);

    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.t('appointmentCancelled'));
  }

  Future<void> _callClient(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      AppSnackbar.show(
        context,
        AppStrings.t('couldNotOpenPhoneDialer'),
        isError: true,
      );
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$digitsOnly');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      AppSnackbar.show(
        context,
        AppStrings.t('couldNotOpenWhatsApp'),
        isError: true,
      );
    }
  }

  Future<_ClientContact> _loadClientPhone() async {
    try {
      final doc = await FirestoreService.instance.getClient(
        appointment.clientId,
      );
      final data = doc.data() as Map<String, dynamic>?;
      return _ClientContact(phone: data?['phone']);
    } catch (_) {
      return _ClientContact(phone: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    final locale = AppStrings.currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_ClientContact>(
        future: _loadClientPhone(),
        builder: (context, snapshot) {
          final phone = snapshot.data?.phone;
          final hasPhone = phone != null && phone.isNotEmpty;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 200,
                backgroundColor: AppColors.primary,
                actions: [
                  IconButton(
                    onPressed: () => _editAppointment(context),
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => _cancelAppointment(context),
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                appointment.clientName.isNotEmpty
                                    ? appointment.clientName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              appointment.clientName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: [
                      if (hasPhone) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _ActionPill(
                                icon: Icons.call,
                                label: AppStrings.t('call'),
                                color: AppColors.primary,
                                onTap: () => _callClient(context, phone),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionPill(
                                icon: Icons.chat,
                                label: AppStrings.t('whatsapp'),
                                color: const Color(0xFF25D366),
                                onTap: () => _openWhatsApp(context, phone),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      _InfoCard(
                        children: [
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: AppStrings.t('date'),
                            value: DateFormat(
                              'EEE, MMM d',
                              locale,
                            ).format(appointment.startTime),
                          ),
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            label: AppStrings.t('hour'),
                            value:
                                '${DateFormat('h:mm a', locale).format(appointment.startTime)} – ${DateFormat('h:mm a', locale).format(appointment.endTime)}',
                          ),
                          _InfoRow(
                            icon: Icons.timer_outlined,
                            label: AppStrings.t('duration'),
                            value: '${appointment.totalDurationMinutes} min',
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _InfoCard(
                        title: AppStrings.t('serviceItemsTitle'),
                        titleIcon: Icons.content_cut_outlined,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: appointment.services.map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${s.quantity}x ${s.name}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _InfoCard(
                        title: AppStrings.t('payment'),
                        titleIcon: Icons.credit_card,
                        children: [
                          _InfoRow(
                            icon: Icons.attach_money,
                            label: AppStrings.t('total'),
                            value: '\$${appointment.total.toStringAsFixed(2)}',
                            bold: true,
                          ),
                          _InfoRow(
                            icon: Icons.payments_outlined,
                            label: AppStrings.t('paymentMethod'),
                            value: appointment.paymentMethod,
                            isLast: true,
                          ),
                        ],
                      ),
                      if (appointment.notes != null &&
                          appointment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _InfoCard(
                          title: AppStrings.t('notes2'),
                          titleIcon: Icons.notes,
                          children: [
                            Text(
                              appointment.notes!,
                              style: const TextStyle(color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: () => _editAppointment(context),
                        child: Text(AppStrings.t('edit')),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => _cancelAppointment(context),
                        child: Text(AppStrings.t('cancel')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClientContact {
  final String? phone;
  _ClientContact({this.phone});
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 19),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String? title;
  final IconData? titleIcon;
  final List<Widget> children;

  const _InfoCard({this.title, this.titleIcon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Icon(titleIcon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 12.5,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  final bool bold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 15, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
