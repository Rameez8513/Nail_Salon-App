import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../models/client_model.dart';
import '../../../models/employee_model.dart';
import '../../../models/service_model.dart';
import '../../../models/appointment_model.dart';
import '../widgets/select_client_sheet.dart';
import '../../employee/widgets/select_employee_sheet.dart';
import '../widgets/select_services_sheet.dart';
import '../widgets/step_progress_indicator.dart';
import '../../../core/widgets/app_bottom_sheet.dart';

class NewAppointmentScreen extends StatefulWidget {
  final DateTime initialDate;
  final AppointmentModel? existingAppointment;

  const NewAppointmentScreen({
    super.key,
    required this.initialDate,
    this.existingAppointment,
  });

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  int _currentStep = 0;

  ClientModel? _selectedClient;
  EmployeeModel? _selectedEmployee;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool? _isAvailable;
  String? _conflictMessage;
  bool _isCheckingAvailability = false;
  bool _isSaving = false;

  final Map<String, ServiceModel> _selectedServices = {};
  final Map<String, int> _serviceQuantities = {};

  late final TextEditingController _discountController;
  late final TextEditingController _notesController;
  late String _paymentMethod;

  bool get _isEditing => widget.existingAppointment != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAppointment;
    final now = DateTime.now();

    if (existing != null) {
      _selectedClient = ClientModel(
        id: existing.clientId,
        name: existing.clientName,
        phone: null,
        notes: null,
        createdAt: now,
        updatedAt: now,
      );
      if (existing.employeeId != null) {
        _selectedEmployee = EmployeeModel(
          id: existing.employeeId!,
          name: existing.employeeName ?? '',
          createdAt: now,
        );
      }
      _selectedDate = existing.startTime;
      _selectedTime = TimeOfDay(
        hour: existing.startTime.hour,
        minute: existing.startTime.minute,
      );

      for (final item in existing.services) {
        final pseudoService = ServiceModel(
          id: item.serviceId,
          name: item.name,
          price: item.price,
          durationMinutes: item.durationMinutes,
          notes: null,
          createdAt: now,
          updatedAt: now,
        );
        _selectedServices[item.serviceId] = pseudoService;
        _serviceQuantities[item.serviceId] = item.quantity;
      }

      _discountController = TextEditingController(
        text: existing.discount.toStringAsFixed(2),
      );
      _notesController = TextEditingController(text: existing.notes ?? '');
      _paymentMethod = existing.paymentMethod;
    } else {
      _selectedDate = widget.initialDate;
      _discountController = TextEditingController(text: '0.00');
      _notesController = TextEditingController();
      _paymentMethod = AppStrings.t('cash');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAvailability());
  }

  @override
  void dispose() {
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);

  DateTime get _startDateTime => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );

  int get _totalDuration {
    int total = 0;
    _selectedServices.forEach((id, service) {
      total += service.durationMinutes * (_serviceQuantities[id] ?? 1);
    });
    return total == 0 ? 30 : total;
  }

  DateTime get _endDateTime =>
      _startDateTime.add(Duration(minutes: _totalDuration));

  double get _subtotal {
    double total = 0;
    _selectedServices.forEach((id, service) {
      total += service.price * (_serviceQuantities[id] ?? 1);
    });
    return total;
  }

  double get _discount => double.tryParse(_discountController.text.trim()) ?? 0;
  double get _total => (_subtotal - _discount).clamp(0, double.infinity);

  Future<void> _pickClient() async {
    final client = await AppBottomSheet.show<ClientModel>(
      context,
      title: AppStrings.t('selectClientTitle'),
      child: const SelectClientSheet(),
    );
    if (client != null) {
      setState(() => _selectedClient = client);
      _checkAvailability();
    }
  }

  Future<void> _pickEmployee() async {
    final employee = await AppBottomSheet.show<EmployeeModel>(
      context,
      title: AppStrings.t('selectEmployeeTitle'),
      child: const SelectEmployeeSheet(),
    );
    if (employee != null) {
      setState(() => _selectedEmployee = employee);
      _checkAvailability();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      _checkAvailability();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
      setState(() => _selectedTime = picked);
      _checkAvailability();
    }
  }

  /// Conflicts are only checked against appointments assigned to the SAME
  /// employee — different employees can be booked at the same time.
  Future<void> _checkAvailability() async {
    setState(() => _isCheckingAvailability = true);

    final docs = await FirestoreService.instance.getAppointmentsForDate(
      _dateKey,
    );
    final existingAppointments = docs
        .map(
          (d) =>
              AppointmentModel.fromMap(d.id, d.data() as Map<String, dynamic>),
        )
        .where(
          (a) =>
              widget.existingAppointment == null ||
              a.id != widget.existingAppointment!.id,
        )
        .where(
          (a) =>
              _selectedEmployee == null ||
              a.employeeId == _selectedEmployee!.id,
        )
        .toList();

    final newStart = _startDateTime;
    final newEnd = _endDateTime;

    AppointmentModel? conflict;
    for (final appt in existingAppointments) {
      final overlap =
          newStart.isBefore(appt.endTime) && newEnd.isAfter(appt.startTime);
      if (overlap) {
        conflict = appt;
        break;
      }
    }

    if (!mounted) return;
    setState(() {
      _isCheckingAvailability = false;
      if (conflict != null) {
        _isAvailable = false;
        _conflictMessage =
            '${conflict.clientName} (${DateFormat('h:mm a').format(conflict.startTime)} - ${DateFormat('h:mm a').format(conflict.endTime)})';
      } else {
        _isAvailable = true;
        _conflictMessage = null;
      }
    });
  }

  Future<void> _pickServices() async {
    final result = await AppBottomSheet.show<List<ServiceModel>>(
      context,
      title: AppStrings.t('selectServicesTitle'),
      child: SelectServicesSheet(
        alreadySelectedIds: _selectedServices.keys.toList(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedServices.clear();
        for (final service in result) {
          _selectedServices[service.id] = service;
          _serviceQuantities.putIfAbsent(service.id, () => 1);
        }
        _serviceQuantities.removeWhere(
          (key, _) => !_selectedServices.containsKey(key),
        );
      });
      _checkAvailability();
    }
  }

  void _changeQuantity(String serviceId, int newQty) {
    setState(() => _serviceQuantities[serviceId] = newQty);
    _checkAvailability();
  }

  Future<void> _saveAppointment() async {
    if (_selectedClient == null || _selectedServices.isEmpty) return;

    setState(() => _isSaving = true);

    await _checkAvailability();

    if (_isAvailable == false) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      AppSnackbar.show(
        context,
        AppStrings.t('slotNoLongerAvailable'),
        isError: true,
      );
      setState(() => _currentStep = 0);
      return;
    }

    final serviceItems = _selectedServices.values.map((s) {
      return AppointmentServiceItem(
        serviceId: s.id,
        name: s.name,
        price: s.price,
        durationMinutes: s.durationMinutes,
        quantity: _serviceQuantities[s.id] ?? 1,
      ).toMap();
    }).toList();

    final data = {
      'clientId': _selectedClient!.id,
      'clientName': _selectedClient!.name,
      'employeeId': _selectedEmployee?.id,
      'employeeName': _selectedEmployee?.name,
      'services': serviceItems,
      'dateKey': _dateKey,
      'startTime': _startDateTime.toIso8601String(),
      'endTime': _endDateTime.toIso8601String(),
      'discount': _discount,
      'paymentMethod': _paymentMethod,
      'notes': _notesController.text.trim(),
    };

    if (_isEditing) {
      FirestoreService.instance.updateAppointment(
        widget.existingAppointment!.id,
        data,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.show(context, AppStrings.t('appointmentUpdated'));
    } else {
      data['createdAt'] = DateTime.now().toIso8601String();
      FirestoreService.instance.addAppointment(data);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.show(context, AppStrings.t('appointmentBooked'));
    }
  }

  bool get _canGoNext {
    if (_isCheckingAvailability) return false;
    if (_currentStep == 0)
      return _selectedClient != null && _isAvailable != false;
    if (_currentStep == 1)
      return _selectedServices.isNotEmpty && _isAvailable != false;
    return _isAvailable != false;
  }

  Widget _buildAvailabilityBanner() {
    if (_isCheckingAvailability) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.border.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.t('checkingAvailability'),
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
          ],
        ),
      );
    }

    if (_isAvailable == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isAvailable!
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable! ? Icons.check_circle : Icons.error_outline,
            color: _isAvailable! ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAvailable!
                      ? AppStrings.t('available')
                      : AppStrings.t('timeSlotConflict'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _isAvailable!
                        ? AppColors.success
                        : AppColors.warning,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _isAvailable!
                      ? '${DateFormat('h:mm a').format(_startDateTime)} - ${DateFormat('h:mm a').format(_endDateTime)}'
                      : '${AppStrings.t('overlapsWith')} ${_conflictMessage ?? AppStrings.t('anotherAppointment')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing
              ? AppStrings.t('editAppointment')
              : AppStrings.t('newAppointment'),
        ),
      ),
      body: Column(
        children: [
          StepProgressIndicator(
            currentStep: _currentStep,
            labels: [
              AppStrings.t('client'),
              AppStrings.t('services'),
              AppStrings.t('confirmStep'),
            ],
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildStepContent(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textDark,
                      ),
                      child: Text(AppStrings.t('back')),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: (!_canGoNext || _isSaving)
                        ? null
                        : () {
                            if (_currentStep < 2) {
                              setState(() => _currentStep++);
                            } else {
                              _saveAppointment();
                            }
                          },
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _currentStep < 2
                                ? AppStrings.t('next')
                                : (_isEditing
                                      ? AppStrings.t('saveChanges')
                                      : AppStrings.t('saveAppointment')),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildClientStep();
      case 1:
        return _buildServicesStep();
      default:
        return _buildConfirmStep();
    }
  }

  Widget _buildClientStep() {
    return SingleChildScrollView(
      key: const ValueKey('step0'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.t('client'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          _SelectTile(
            icon: Icons.person_outline,
            label: _selectedClient?.name ?? AppStrings.t('selectClient'),
            onTap: _pickClient,
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.t('employee'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          _SelectTile(
            icon: Icons.badge_outlined,
            label: _selectedEmployee?.name ?? AppStrings.t('selectEmployee'),
            onTap: _pickEmployee,
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.t('date'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          _SelectTile(
            icon: Icons.calendar_today_outlined,
            label: DateFormat(
              'EEEE, MMM d, yyyy',
              AppStrings.currentLanguage,
            ).format(_selectedDate),
            onTap: _pickDate,
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.t('time'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          _SelectTile(
            icon: Icons.access_time_rounded,
            label: _selectedTime.format(context),
            onTap: _pickTime,
          ),
          const SizedBox(height: 20),
          _buildAvailabilityBanner(),
        ],
      ),
    );
  }

  Widget _buildServicesStep() {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickServices,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.4),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                '+ ${AppStrings.t('selectServicesTitle')}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._selectedServices.values.map((service) {
            final qty = _serviceQuantities[service.id] ?? 1;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${service.durationMinutes} min',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: qty > 1
                            ? () => _changeQuantity(service.id, qty - 1)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        color: AppColors.primary,
                      ),
                      Text(
                        '$qty',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        onPressed: () => _changeQuantity(service.id, qty + 1),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  Text(
                    '\$${(service.price * qty).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }),
          if (_selectedServices.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildAvailabilityBanner(),
            const SizedBox(height: 16),
          ],
          Text(
            AppStrings.t('discount'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: AppStrings.t('discountHint'),
              prefixIcon: const Icon(Icons.discount_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.t('paymentMethod'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _PaymentChip(
                label: AppStrings.t('cash'),
                icon: Icons.payments_outlined,
                isSelected: _paymentMethod == AppStrings.t('cash'),
                onTap: () =>
                    setState(() => _paymentMethod = AppStrings.t('cash')),
              ),
              const SizedBox(width: 10),
              _PaymentChip(
                label: AppStrings.t('creditCard'),
                icon: Icons.credit_card,
                isSelected: _paymentMethod == AppStrings.t('creditCard'),
                onTap: () =>
                    setState(() => _paymentMethod = AppStrings.t('creditCard')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvailabilityBanner(),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.t('client'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _SummaryRow(AppStrings.t('name'), _selectedClient?.name ?? ''),
                _SummaryRow(
                  AppStrings.t('employee'),
                  _selectedEmployee?.name ?? '—',
                ),
                _SummaryRow(
                  AppStrings.t('date'),
                  DateFormat(
                    'EEEE, MMM d',
                    AppStrings.currentLanguage,
                  ).format(_selectedDate),
                ),
                _SummaryRow(
                  AppStrings.t('time'),
                  '${DateFormat('h:mm a').format(_startDateTime)} - ${DateFormat('h:mm a').format(_endDateTime)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${AppStrings.t('services')} (${_selectedServices.length})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ..._selectedServices.values.map((s) {
                  final qty = _serviceQuantities[s.id] ?? 1;
                  return _SummaryRow(
                    '${qty}x ${s.name}',
                    '\$${(s.price * qty).toStringAsFixed(2)}',
                  );
                }),
                const Divider(height: 24),
                _SummaryRow(
                  AppStrings.t('subtotal'),
                  '\$${_subtotal.toStringAsFixed(2)}',
                ),
                if (_discount > 0)
                  _SummaryRow(
                    AppStrings.t('discount'),
                    '-\$${_discount.toStringAsFixed(2)}',
                  ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.t('total'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                _SummaryRow(AppStrings.t('paymentLabel'), _paymentMethod),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.t('notes'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(hintText: AppStrings.t('optional')),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SelectTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textGrey,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13.5),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
