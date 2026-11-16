import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _items => _db.collection('items');

  // Membaca data inventaris secara real-time
  Stream<List<ItemModel>> getItems() {
    return _items.orderBy('created_at', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => ItemModel.fromDocument(doc)).toList();
    });
  }

  // CREATE
  Future<void> addItem(ItemModel item) async {
    final doc = _items.doc();

    await doc.set({
      ...item.toMap(),
      'item_id': doc.id,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE
  Future<void> updateItem(ItemModel item) async {
    await _items.doc(item.id).update({
      'item_name': item.itemName,
      'category': item.category,
      'code': item.code,
      'status': item.status,
      'image': item.image,
      'spesification': item.spesification,
    });
  }

  // DELETE
  Future<void> deleteItem(String id) async {
    await _items.doc(id).delete();
  }

  // Membuat data dummy jika koleksi masih kosong
  Future<void> seedDummyItems() async {
    final snapshot = await _items.limit(1).get();

    if (snapshot.docs.isNotEmpty) return;

    final dummyItems = [
      {
        'item_name': 'Laptop ASUS',
        'category': 'Elektronik',
        'code': 'LAB001',
        'status': 'Available',
        'image':
            'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800',
        'spesification': 'Laptop praktikum pemrograman, RAM 8GB.',
      },
      {
        'item_name': 'Mikroskop',
        'category': 'Optik',
        'code': 'LAB002',
        'status': 'Borrowed',
        'image':
            'https://images.unsplash.com/photo-1581093458791-9d42e3c5e3b4?w=800',
        'spesification': 'Mikroskop untuk pengamatan objek.',
      },
      {
        'item_name': 'Arduino Uno',
        'category': 'Elektronik',
        'code': 'LAB003',
        'status': 'Available',
        'image':
            'https://images.unsplash.com/photo-1553406830-ef2513450d76?w=800',
        'spesification': 'Board mikrokontroler untuk praktikum IoT.',
      },
      {
        'item_name': 'Multimeter',
        'category': 'Pengukuran',
        'code': 'LAB004',
        'status': 'Available',
        'image':
            'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800',
        'spesification': 'Alat ukur tegangan, arus, dan hambatan.',
      },
      {
        'item_name': 'Projector',
        'category': 'Elektronik',
        'code': 'LAB005',
        'status': 'Borrowed',
        'image':
            'https://images.unsplash.com/photo-1528395874238-34d7b4f8c5?w=800',
        'spesification': 'Proyektor untuk presentasi laboratorium.',
      },
      {
        'item_name': 'Breadboard',
        'category': 'Komponen',
        'code': 'LAB006',
        'status': 'Available',
        'image':
            'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
        'spesification': 'Papan rangkaian percobaan elektronik.',
      },
    ];

    final batch = _db.batch();

    for (final item in dummyItems) {
      final doc = _items.doc();

      batch.set(doc, {
        ...item,
        'item_id': doc.id,
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // Transaksi peminjaman
  Future<void> borrowItem({
    required String uid,
    required ItemModel item,
  }) async {
    final borrowings = _db
        .collection('users')
        .doc(uid)
        .collection('borrowings');

    final borrowDoc = borrowings.doc();
    final itemDoc = _items.doc(item.id);

    await _db.runTransaction((transaction) async {
      final itemSnapshot = await transaction.get(itemDoc);

      if (!itemSnapshot.exists) {
        throw Exception('Alat tidak ditemukan.');
      }

      final data = itemSnapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Alat tidak ditemukan.');
      }

      if (data['status'] != 'Available') {
        throw Exception('Alat sedang dipinjam.');
      }

      transaction.update(itemDoc, {'status': 'Borrowed'});

      transaction.set(borrowDoc, {
        'borrow_id': borrowDoc.id,
        'item_id': item.id,
        'item_name': item.itemName,
        'borrow_date': FieldValue.serverTimestamp(),
      });
    });
  }
}
