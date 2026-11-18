import 'package:cloud_firestore/cloud_firestore.dart';

enum LoanStatus { borrowed, returned }

class Loan {
  final String id;
  final String itemId;
  final String itemTitle;
  final String userId;
  final String userName;
  final DateTime borrowedAt;
  final DateTime? returnedAt;
  final LoanStatus status;

  const Loan({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.userId,
    required this.userName,
    required this.borrowedAt,
    required this.returnedAt,
    required this.status,
  });

  bool get isActive => status == LoanStatus.borrowed;

  factory Loan.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Loan(
      id: doc.id,
      itemId: (d['itemId'] ?? '') as String,
      itemTitle: (d['itemTitle'] ?? '') as String,
      userId: (d['userId'] ?? '') as String,
      userName: (d['userName'] ?? '') as String,
      // serverTimestamp bisa null sesaat pada snapshot lokal
      borrowedAt:
          (d['borrowedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnedAt: (d['returnedAt'] as Timestamp?)?.toDate(),
      status: d['status'] == 'returned'
          ? LoanStatus.returned
          : LoanStatus.borrowed,
    );
  }
}