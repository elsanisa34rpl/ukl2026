import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String itemName;
  final String category;
  final String code;
  final String status;
  final String image;
  final String spesification;
  final Timestamp? createdAt;

  const ItemModel({
    required this.id,
    required this.itemName,
    required this.category,
    required this.code,
    required this.status,
    required this.image,
    required this.spesification,
    this.createdAt,
  });

  factory ItemModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ItemModel(
      id: doc.id,
      itemName: (data['item_name'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      code: (data['code'] ?? '').toString(),
      status: (data['status'] ?? 'Available').toString(),
      image: (data['image'] ?? '').toString(),
      spesification: (data['spesification'] ?? '').toString(),
      createdAt: data['created_at'] is Timestamp
          ? data['created_at'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'item_id': id,
        'item_name': itemName,
        'category': category,
        'code': code,
        'status': status,
        'image': image,
        'spesification': spesification,
        'created_at': createdAt ?? FieldValue.serverTimestamp(),
      };
}