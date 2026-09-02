import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/appointment_model.dart';
import '../screens/appointment_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/constants/app_strings.dart';

class WeekCalendarView extends StatefulWidget {
  final DateTime weekStart;
  final String? employeeId;

  const WeekCalendarView({super.key, required this.weekStart, this.employeeId});

  @override
  State<WeekCalendarView> createState() => _WeekCalendarViewState();
}

class _WeekCalendarViewState extends State<WeekCalendarView> {
  static const int startHour = 0;
  static const int endHour = 24;
  static const double hourHeight = 70;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final offset = (now.hour * hourHeight) - 100;
      if (_scrollController.hasClients && offset > 0) {
        _scrollController.jumpTo(offset);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h $period';
  }

  Color _colorForAppointment(String id) {
    final index = id.hashCode.abs() % AppColors.appointmentPalette.length;
    return AppColors.appointmentPalette[index];
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppSettingsProvider>();
    final days = List.generate(
      7,
      (i) => widget.weekStart.add(Duration(days: i)),
    );
    final weekEnd = days.last;

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance.appointmentsForWeekStream(
        widget.weekStart,
        weekEnd,
      ),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final appointments = docs
            .map(
              (d) => AppointmentModel.fromMap(
                d.id,
                d.data() as Map<String, dynamic>,
              ),
            )
            .where(
              (a) =>
                  widget.employeeId == null ||
                  a.employeeId == widget.employeeId,
            )
            .toList();

        return Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 44),
                ...days.map((day) {
                  final isToday = _isSameDay(day, DateTime.now());
                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          DateFormat(
                            'E',
                            AppStrings.currentLanguage,
                          ).format(day).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isToday
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SizedBox(
                  height: hourHeight * (endHour - startHour),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44,
                        child: Column(
                          children: List.generate(endHour - startHour, (i) {
                            return Container(
                              height: hourHeight,
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.only(right: 6, top: 2),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.border,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                _formatHour(startHour + i),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      ...days.map((day) {
                        final dayAppointments = appointments
                            .where((a) => _isSameDay(a.startTime, day))
                            .toList();
                        return Expanded(
                          child: Stack(
                            children: [
                              Column(
                                children: List.generate(
                                  endHour - startHour,
                                  (i) => Container(
                                    height: hourHeight,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: AppColors.border,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ...dayAppointments.map((appt) {
                                final startMinutesFromTop =
                                    (appt.startTime.hour - startHour) * 60 +
                                    appt.startTime.minute;
                                final top =
                                    (startMinutesFromTop / 60) * hourHeight;
                                final height =
                                    (appt.totalDurationMinutes / 60) *
                                    hourHeight;
                                final color = _colorForAppointment(appt.id);

                                return Positioned(
                                  top: top < 0 ? 0 : top,
                                  left: 2,
                                  right: 2,
                                  height: height < 28 ? 28 : height,
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AppointmentDetailScreen(
                                          appointment: appt,
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(7),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${DateFormat('h:mm a', AppStrings.currentLanguage).format(appt.startTime)}\n${appt.clientName}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
