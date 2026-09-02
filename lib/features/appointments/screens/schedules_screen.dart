import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/routes/slide_up_route.dart';
import '../../../models/appointment_model.dart';
import '../../../models/employee_model.dart';
import '../widgets/date_strip.dart';
import '../widgets/appointment_card.dart';
import '../widgets/week_calendar_view.dart';
import 'new_appointment_screen.dart';
import 'appointment_history_screen.dart';
import 'appointment_detail_screen.dart';

enum ScheduleViewMode { day, week }

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  DateTime _selectedDate = DateTime.now();
  ScheduleViewMode _viewMode = ScheduleViewMode.day;
  String? _selectedEmployeeId;

  String? _cachedDateKey;
  late Stream<QuerySnapshot> _dayStream;

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);

  DateTime get _weekStart {
    final weekday = _selectedDate.weekday;
    return _selectedDate.subtract(Duration(days: weekday % 7));
  }

  Stream<QuerySnapshot> _getDayStream() {
    if (_cachedDateKey != _dateKey) {
      _cachedDateKey = _dateKey;
      _dayStream = FirestoreService.instance.appointmentsForDateStream(
        _dateKey,
      );
    }
    return _dayStream;
  }

  void _openNewAppointment() {
    Navigator.of(context).push(
      SlideUpRoute(page: NewAppointmentScreen(initialDate: _selectedDate)),
    );
  }

  void _openHistory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AppointmentHistoryScreen()));
  }

  void _shiftWeek(int delta) {
    setState(
      () => _selectedDate = _selectedDate.add(Duration(days: 7 * delta)),
    );
  }

  void _shiftDay(int delta) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: delta)));
  }

  Future<void> _jumpToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == _dateKey;
    final weekEnd = _weekStart.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t('schedules')),
        actions: [
          IconButton(onPressed: _openHistory, icon: const Icon(Icons.history)),
          IconButton(
            onPressed: _openNewAppointment,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _EmployeeTabsBar(
            selectedEmployeeId: _selectedEmployeeId,
            onSelected: (id) => setState(() => _selectedEmployeeId = id),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ViewToggle(
              mode: _viewMode,
              onChanged: (mode) => setState(() => _viewMode = mode),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _viewMode == ScheduleViewMode.day
                      ? _shiftDay(-1)
                      : _shiftWeek(-1),
                  icon: const Icon(
                    Icons.chevron_left,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    _viewMode == ScheduleViewMode.day
                        ? (isToday
                              ? '${AppStrings.t('today')} ${DateFormat('MMMM d', AppStrings.currentLanguage).format(_selectedDate)}'
                              : DateFormat(
                                  'EEE, MMMM d',
                                  AppStrings.currentLanguage,
                                ).format(_selectedDate))
                        : '${DateFormat('MMM d', AppStrings.currentLanguage).format(_weekStart)} – ${DateFormat('MMM d, yyyy', AppStrings.currentLanguage).format(weekEnd)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _viewMode == ScheduleViewMode.day
                      ? _shiftDay(1)
                      : _shiftWeek(1),
                  icon: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: _jumpToDate,
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_viewMode == ScheduleViewMode.day) ...[
            const SizedBox(height: 8),
            DateStrip(
              selectedDate: _selectedDate,
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getDayStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final appointments =
                      docs
                          .map(
                            (d) => AppointmentModel.fromMap(
                              d.id,
                              d.data() as Map<String, dynamic>,
                            ),
                          )
                          .where(
                            (a) =>
                                _selectedEmployeeId == null ||
                                a.employeeId == _selectedEmployeeId,
                          )
                          .toList()
                        ..sort((a, b) => a.startTime.compareTo(b.startTime));

                  return ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    children: [
                      if (appointments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: EmptyState(
                            icon: Icons.calendar_today_outlined,
                            title: AppStrings.t('noAppointments'),
                            subtitle: AppStrings.t('nothingBookedToday'),
                            buttonLabel: AppStrings.t('newAppointment'),
                            onPressed: _openNewAppointment,
                          ),
                        )
                      else
                        ...appointments.asMap().entries.map((entry) {
                          return FadeSlideIn(
                            index: entry.key,
                            child: AppointmentCard(
                              appointment: entry.value,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AppointmentDetailScreen(
                                    appointment: entry.value,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          onTap: _openNewAppointment,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.4,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_circle,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.t('newAppointment'),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ] else
            Expanded(
              child: WeekCalendarView(
                weekStart: _weekStart,
                employeeId: _selectedEmployeeId,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmployeeTabsBar extends StatelessWidget {
  final String? selectedEmployeeId;
  final ValueChanged<String?> onSelected;

  const _EmployeeTabsBar({
    required this.selectedEmployeeId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService.instance.employeesStream(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final employeesList = docs
            .map(
              (d) =>
                  EmployeeModel.fromMap(d.id, d.data() as Map<String, dynamic>),
            )
            .toList();

        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _EmployeeChip(
                label: AppStrings.t('general'),
                isSelected: selectedEmployeeId == null,
                onTap: () => onSelected(null),
              ),
              const SizedBox(width: 8),
              ...employeesList.map((employee) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _EmployeeChip(
                    label: employee.name,
                    isSelected: selectedEmployeeId == employee.id,
                    onTap: () => onSelected(employee.id),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _EmployeeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmployeeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final ScheduleViewMode mode;
  final ValueChanged<ScheduleViewMode> onChanged;

  const _ViewToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: AppStrings.t('day'),
              isSelected: mode == ScheduleViewMode.day,
              onTap: () => onChanged(ScheduleViewMode.day),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: AppStrings.t('week'),
              isSelected: mode == ScheduleViewMode.week,
              onTap: () => onChanged(ScheduleViewMode.week),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
