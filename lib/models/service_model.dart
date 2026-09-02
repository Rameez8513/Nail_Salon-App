class ServiceModel {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromMap(String id, Map<String, dynamic> map) {
    return ServiceModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 0,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt'] ?? map['createdAt']),
    );
  }
}
