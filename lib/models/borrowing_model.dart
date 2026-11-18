import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowingModel {
  final String id;
  final String itemId;
  final String itemName;
  final String userId;
  final String userName;
  final Timestamp? borrowDate;
  final Timestamp? returnDate;

  const BorrowingModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.userId,
    required this.userName,
    this.borrowDate,
    this.returnDate,
  });

  bool get isActive => returnDate == null;

  factory BorrowingModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final userId =
        doc.reference.parent.parent?.id ?? (data['user_id'] ?? '').toString();

    return BorrowingModel(
      id: doc.id,
      itemId: (data['item_id'] ?? '').toString(),
      itemName: (data['item_name'] ?? 'Alat').toString(),
      userId: userId,
      userName: (data['user_name'] ?? userId).toString(),
      borrowDate: data['borrow_date'] is Timestamp
          ? data['borrow_date'] as Timestamp
          : null,
      returnDate: data['return_date'] is Timestamp
          ? data['return_date'] as Timestamp
          : null,
    );
  }
}
