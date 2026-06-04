import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Category(
      id: doc.id,
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name.trim(),
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
