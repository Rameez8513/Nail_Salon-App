class AppointmentServiceItem {
  final String serviceId;
  final String name;
  final double price;
  final int durationMinutes;
  final int quantity;

  AppointmentServiceItem({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.quantity,
  });

  double get total => price * quantity;
  int get totalDuration => durationMinutes * quantity;

  Map<String, dynamic> toMap() => {
    'serviceId': serviceId,
    'name': name,
    'price': price,
    'durationMinutes': durationMinutes,
    'quantity': quantity,
  };

  factory AppointmentServiceItem.fromMap(Map<String, dynamic> map) {
    return AppointmentServiceItem(
      serviceId: map['serviceId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 0,
      quantity: map['quantity'] ?? 1,
    );
  }
}

class AppointmentModel {
  final String id;
  final String clientId;
  final String clientName;
  final String? employeeId;
  final String? employeeName;
  final List<AppointmentServiceItem> services;
  final String dateKey;
  final DateTime startTime;
  final DateTime endTime;
  final double discount;
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.employeeId,
    this.employeeName,
    required this.services,
    required this.dateKey,
    required this.startTime,
    required this.endTime,
    required this.discount,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  double get subtotal => services.fold(0, (sum, s) => sum + s.total);
  double get total => (subtotal - discount).clamp(0, double.infinity);
  int get totalDurationMinutes =>
      services.fold(0, (sum, s) => sum + s.totalDuration);

  factory AppointmentModel.fromMap(String id, Map<String, dynamic> map) {
    return AppointmentModel(
      id: id,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      employeeId: map['employeeId'],
      employeeName: map['employeeName'],
      services: (map['services'] as List<dynamic>? ?? [])
          .map(
            (s) => AppointmentServiceItem.fromMap(Map<String, dynamic>.from(s)),
          )
          .toList(),
      dateKey: map['dateKey'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      discount: (map['discount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'services': services.map((s) => s.toMap()).toList(),
      'dateKey': dateKey,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'discount': discount,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
