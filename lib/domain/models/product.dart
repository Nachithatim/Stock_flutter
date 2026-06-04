import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.quantity,
    required this.threshold,
    required this.unitPrice,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final int quantity;
  final int threshold;
  final double unitPrice;
  final DateTime createdAt;

  bool get isBelowThreshold => quantity <= threshold;

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      threshold: (data['threshold'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name.trim(),
    'categoryId': categoryId,
    'categoryName': categoryName.trim(),
    'quantity': quantity,
    'threshold': threshold,
    'unitPrice': unitPrice,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
