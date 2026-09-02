class EmployeeModel {
  final String id;
  final String name;
  final String? phone;
  final String? role;
  final DateTime createdAt;

  EmployeeModel({
    required this.id,
    required this.name,
    this.phone,
    this.role,
    required this.createdAt,
  });

  factory EmployeeModel.fromMap(String id, Map<String, dynamic> map) {
    return EmployeeModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'],
      role: map['role'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
