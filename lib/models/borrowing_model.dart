import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowingModel {
  final String id;
  final String itemId;
  final String itemName;
  final Timestamp? borrowDate;
  final Timestamp? returnDate;

  const BorrowingModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    this.borrowDate,
    this.returnDate,
  });

  bool get isActive => returnDate == null;

  factory BorrowingModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return BorrowingModel(
      id: doc.id,
      itemId: (data['item_id'] ?? '').toString(),
      itemName: (data['item_name'] ?? 'Alat').toString(),
      borrowDate: data['borrow_date'] is Timestamp
          ? data['borrow_date'] as Timestamp
          : null,
      returnDate: data['return_date'] is Timestamp
          ? data['return_date'] as Timestamp
          : null,
    );
  }
}
