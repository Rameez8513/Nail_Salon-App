enum StockStatus { inStock, lowStock, outOfStock }

class ProductModel {
  final String id;
  final String name;
  final int currentStock;
  final int minimumStock;
  final double? price;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minimumStock,
    this.price,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  StockStatus get status {
    if (currentStock <= 0) return StockStatus.outOfStock;
    if (currentStock <= minimumStock) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      currentStock: map['currentStock'] ?? 0,
      minimumStock: map['minimumStock'] ?? 0,
      price: map['price'] != null ? (map['price']).toDouble() : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt'] ?? map['createdAt']),
    );
  }
}
