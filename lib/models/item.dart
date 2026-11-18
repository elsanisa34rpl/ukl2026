import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final int total;
  final int available;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.total,
    required this.available,
  });

  factory Item.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final total = ((data['total'] ?? 1) as num).toInt();
    return Item(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      category: (data['category'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      total: total,
      available: ((data['available'] ?? total) as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'imageUrl': imageUrl,
    'total': total,
    'available': available,
  };
}
