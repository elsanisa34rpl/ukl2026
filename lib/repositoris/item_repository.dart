import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_exception.dart';
import '../models/item.dart';

class ItemRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('items');

  Stream<List<Item>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Item.fromDoc).toList());

  Future<void> add(Item item) => _col.add({
        ...item.toMap(),
        'available': item.total, // barang baru: semua unit tersedia
        'createdAt': FieldValue.serverTimestamp(),
      });

  /// Saat total stok diubah, 'available' ikut disesuaikan dengan selisihnya
  /// di dalam transaction agar tidak menimpa peminjaman yang sedang terjadi.
  Future<void> update(Item item) => _db.runTransaction((tx) async {
        final ref = _col.doc(item.id);
        final snap = await tx.get(ref);
        if (!snap.exists) {
          throw const AppException('Barang sudah tidak ada.');
        }
        final d = snap.data()!;
        final oldTotal = ((d['total'] ?? 1) as num).toInt();
        final oldAvail = ((d['available'] ?? oldTotal) as num).toInt();
        final borrowed = oldTotal - oldAvail;
        if (item.total < borrowed) {
          throw AppException(
              'Total stok tidak boleh kurang dari jumlah yang sedang dipinjam ($borrowed).');
        }
        tx.update(ref, {
          ...item.toMap(),
          'available': max(0, item.total - borrowed),
        });
      });

  /// Barang yang masih dipinjam tidak boleh dihapus.
  Future<void> delete(String id) async {
    final active = await _db
        .collection('loans')
        .where('itemId', isEqualTo: id)
        .where('status', isEqualTo: 'borrowed')
        .limit(1)
        .get();
    if (active.docs.isNotEmpty) {
      throw const AppException(
          'Barang ini masih dipinjam, tidak bisa dihapus.');
    }
    await _col.doc(id).delete();
  }
}