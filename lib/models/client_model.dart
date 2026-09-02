class ClientModel {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientModel({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientModel.fromMap(String id, Map<String, dynamic> map) {
    return ClientModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt'] ?? map['createdAt']),
    );
  }
}
