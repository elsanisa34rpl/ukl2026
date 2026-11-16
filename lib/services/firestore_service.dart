import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _items => _db.collection('items');

  Stream<List<ItemModel>> getItems() {
    return _items.orderBy('created_at', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => ItemModel.fromDocument(doc)).toList(),
    );
  }

  Future<void> addItem(ItemModel item) async {
    final doc = _items.doc();
    await doc.set({
      ...item.toMap(),
      'item_id': doc.id,
      'status': 'Available',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Barang yang sedang dipinjam tidak boleh diubah.
  Future<void> updateItem(ItemModel item) async {
    final ref = _items.doc(item.id);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw Exception('Barang tidak ditemukan.');
      if (snapshot.data()?['status'] == 'Borrowed') {
        throw Exception('Barang sedang dipinjam dan tidak dapat diedit.');
      }
      transaction.update(ref, {
        'item_name': item.itemName,
        'category': item.category,
        'code': item.code,
        'image': item.image,
        'spesification': item.spesification,
      });
    });
  }

  Future<void> deleteItem(String id) async {
    final ref = _items.doc(id);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;
      if (snapshot.data()?['status'] == 'Borrowed') {
        throw Exception('Barang sedang dipinjam dan tidak dapat dihapus.');
      }
      transaction.delete(ref);
    });
  }

  Future<void> borrowItem({required String uid, required ItemModel item}) async {
    final history = _db.collection('users').doc(uid).collection('borrowings');
    final historyDoc = history.doc();
    final itemRef = _items.doc(item.id);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(itemRef);
      if (!snapshot.exists) throw Exception('Barang tidak ditemukan.');
      if (snapshot.data()?['status'] != 'Available') {
        throw Exception('Barang sedang dipinjam.');
      }

      transaction.update(itemRef, {'status': 'Borrowed'});
      transaction.set(historyDoc, {
        'borrow_id': historyDoc.id,
        'item_id': item.id,
        'item_name': item.itemName,
        'item_code': item.code,
        'category': item.category,
        'borrow_date': FieldValue.serverTimestamp(),
        'status': 'Dipinjam',
      });
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getBorrowingHistory(String uid) {
    return _db.collection('users').doc(uid).collection('borrowings')
        .orderBy('borrow_date', descending: true).snapshots();
  }

  Future<void> seedDummyItems() async {
    final snapshot = await _items.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final dummyItems = [
      {'item_name':'Laptop ASUS','category':'Elektronik','code':'LAB001','status':'Available','image':'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=900','spesification':'Laptop praktikum pemrograman, RAM 8GB.'},
      {'item_name':'Mikroskop','category':'Optik','code':'LAB002','status':'Borrowed','image':'https://images.unsplash.com/photo-1581093458791-9d42e3c5e3b4?w=900','spesification':'Mikroskop untuk pengamatan objek.'},
      {'item_name':'Arduino Uno','category':'Elektronik','code':'LAB003','status':'Available','image':'https://images.unsplash.com/photo-1553406830-ef2513450d76?w=900','spesification':'Board mikrokontroler untuk praktikum IoT.'},
      {'item_name':'Multimeter','category':'Pengukuran','code':'LAB004','status':'Available','image':'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=900','spesification':'Alat ukur tegangan, arus, dan hambatan.'},
      {'item_name':'Proyektor','category':'Audio Visual','code':'LAB005','status':'Available','image':'https://images.unsplash.com/photo-1528395874238-34d7b4f8c5?w=900','spesification':'Proyektor untuk presentasi laboratorium.'},
      {'item_name':'Breadboard','category':'Komponen','code':'LAB006','status':'Available','image':'https://images.unsplash.com/photo-1518770660439-4636190af475?w=900','spesification':'Papan rangkaian percobaan elektronik.'},
    ];

    final batch = _db.batch();
    for (final item in dummyItems) {
      final doc = _items.doc();
      batch.set(doc, {...item, 'item_id': doc.id, 'created_at': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }
}
