import 'package:cloud_firestore/cloud_firestore.dart';

enum MovementType { entry, sale }

class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String productName;
  final String categoryId;
  final String categoryName;
  final MovementType type;
  final int quantity;
  final double unitPrice;
  final DateTime createdAt;

  double get total => quantity * unitPrice;

  factory StockMovement.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return StockMovement(
      id: doc.id,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      type: (data['type'] as String?) == 'sale'
          ? MovementType.sale
          : MovementType.entry,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'productId': productId,
    'productName': productName,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'type': type == MovementType.sale ? 'sale' : 'entry',
    'quantity': quantity,
    'unitPrice': unitPrice,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
