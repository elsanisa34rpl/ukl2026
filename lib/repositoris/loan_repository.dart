import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_exception.dart';
import '../models/app_user.dart';
import '../models/item.dart';
import '../models/loan.dart';

class LoanRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _loans =>
      _db.collection('loans');
  CollectionReference<Map<String, dynamic>> get _items =>
      _db.collection('items');

  /// Riwayat milik satu user. Diurutkan di sisi aplikasi agar tidak
  /// membutuhkan composite index di Firestore.
  Stream<List<Loan>> watchByUser(String uid) => _loans
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map(Loan.fromDoc).toList();
        list.sort((a, b) => b.borrowedAt.compareTo(a.borrowedAt));
        return list;
      });

  /// Semua riwayat (khusus admin).
  Stream<List<Loan>> watchAll() => _loans
      .orderBy('borrowedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Loan.fromDoc).toList());

  Future<void> borrow({required Item item, required AppUser user}) async {
    // Cegah meminjam barang yang sama dua kali sebelum dikembalikan.
    final dup = await _loans
        .where('userId', isEqualTo: user.uid)
        .where('itemId', isEqualTo: item.id)
        .where('status', isEqualTo: 'borrowed')
        .limit(1)
        .get();
    if (dup.docs.isNotEmpty) {
      throw const AppException(
          'Kamu masih meminjam barang ini. Kembalikan dulu.');
    }

    await _db.runTransaction((tx) async {
      final itemRef = _items.doc(item.id);
      final snap = await tx.get(itemRef);
      if (!snap.exists) {
        throw const AppException('Barang tidak ditemukan.');
      }
      final available = ((snap.data()!['available'] ?? 0) as num).toInt();
      if (available < 1) {
        throw const AppException('Stok barang sedang habis.');
      }
      tx.update(itemRef, {'available': available - 1});
      tx.set(_loans.doc(), {
        'itemId': item.id,
        'itemTitle': item.title,
        'userId': user.uid,
        'userName': user.name,
        'status': 'borrowed',
        'borrowedAt': FieldValue.serverTimestamp(),
        'returnedAt': null,
      });
    });
  }

  Future<void> giveBack(Loan loan) async {
    await _db.runTransaction((tx) async {
      final loanRef = _loans.doc(loan.id);
      final itemRef = _items.doc(loan.itemId);

      final loanSnap = await tx.get(loanRef);
      if (loanSnap.data()?['status'] != 'borrowed') {
        throw const AppException('Peminjaman ini sudah dikembalikan.');
      }
      final itemSnap = await tx.get(itemRef); // semua read sebelum write

      tx.update(loanRef, {
        'status': 'returned',
        'returnedAt': FieldValue.serverTimestamp(),
      });

      // Jika barang sudah dihapus admin, riwayat tetap bisa diselesaikan.
      if (itemSnap.exists) {
        final d = itemSnap.data()!;
        final total = ((d['total'] ?? 1) as num).toInt();
        final available = ((d['available'] ?? 0) as num).toInt();
        tx.update(itemRef, {'available': min(total, available + 1)});
      }
    });
  }
}