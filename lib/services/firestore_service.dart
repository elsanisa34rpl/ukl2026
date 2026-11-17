import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/borrowing_model.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _items => _db.collection('items');

  CollectionReference<Map<String, dynamic>> _borrowings(String uid) =>
      _db.collection('users').doc(uid).collection('borrowings');

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

  // Riwayat peminjaman milik satu pengguna (real-time, terbaru di atas).
  Stream<List<BorrowingModel>> watchBorrowings(String uid) {
    return _borrowings(uid).snapshots().map((snapshot) {
      final list = snapshot.docs.map(BorrowingModel.fromDocument).toList();

      // borrow_date bisa null sesaat setelah dibuat (server timestamp
      // belum terisi), anggap itu yang paling baru.
      list.sort((a, b) {
        final ta = a.borrowDate?.millisecondsSinceEpoch ?? 9007199254740991;
        final tb = b.borrowDate?.millisecondsSinceEpoch ?? 9007199254740991;
        return tb.compareTo(ta);
      });

      return list;
    });
  }

  // Transaksi peminjaman
  Future<void> borrowItem({
    required String uid,
    required ItemModel item,
  }) async {
    final borrowDoc = _borrowings(uid).doc();
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
        'return_date': null,
      });
    });
  }

  // Transaksi pengembalian: mengisi return_date dan mengembalikan
  // status alat menjadi Available, keduanya atomik.
  Future<void> returnItem({
    required String uid,
    required BorrowingModel borrowing,
  }) async {
    final borrowDoc = _borrowings(uid).doc(borrowing.id);
    final itemDoc =
        borrowing.itemId.isEmpty ? null : _items.doc(borrowing.itemId);

    await _db.runTransaction((transaction) async {
      // Semua read harus dilakukan sebelum write.
      final borrowSnapshot = await transaction.get(borrowDoc);
      final itemSnapshot =
          itemDoc == null ? null : await transaction.get(itemDoc);

      final borrowData = borrowSnapshot.data();
      if (!borrowSnapshot.exists || borrowData == null) {
        throw Exception('Data peminjaman tidak ditemukan.');
      }

      if (borrowData['return_date'] != null) {
        throw Exception('Alat ini sudah dikembalikan.');
      }

      transaction.update(borrowDoc, {
        'return_date': FieldValue.serverTimestamp(),
      });

      // Jika alat sudah dihapus admin, riwayat tetap ditutup.
      if (itemDoc != null && itemSnapshot != null && itemSnapshot.exists) {
        transaction.update(itemDoc, {'status': 'Available'});
      }
    });
  }

  // Data dummy: 30 alat laboratorium.
  // - Id dokumen tetap (seed_LABxxx) sehingga aman dipanggil berulang.
  // - Alat dengan kode yang sudah ada dilewati (tidak ada duplikat).
  // - Penanda meta/seed_v2 mencegah alat yang sudah dihapus muncul lagi.
  Future<void> seedDummyItems() async {
    final marker = _db.collection('meta').doc('seed_v2');

    try {
      final done = await marker.get();
      if (done.exists) return;
    } catch (_) {
      // Penanda tidak terbaca: lanjut, duplikat tetap dicegah lewat kode.
    }

    final existing = await _items.get();
    final codes = existing.docs
        .map((d) => ((d.data() as Map<String, dynamic>)['code'] ?? '')
            .toString())
        .toSet();

    final batch = _db.batch();
    var added = 0;

    for (final item in _dummyItems) {
      final code = item['code']!;
      if (codes.contains(code)) continue;

      final doc = _items.doc('seed_$code');
      batch.set(doc, {
        'item_id': doc.id,
        'item_name': item['item_name'],
        'category': item['category'],
        'code': code,
        'status': item['status'],
        'image': item['image'],
        'spesification': item['spesification'],
        'created_at': FieldValue.serverTimestamp(),
      });
      added++;
    }

    if (added > 0) await batch.commit();

    try {
      await marker.set({'created_at': FieldValue.serverTimestamp()});
    } catch (_) {
      // Tidak fatal.
    }
  }

  static const _u = 'https://images.unsplash.com/';

  static final List<Map<String, String>> _dummyItems = [
    // Komputer
    _d('Laptop ASUS VivoBook', 'Komputer', 'LAB001', 'Available',
        'photo-1496181133206-80ce9b88a853',
        'Laptop praktikum pemrograman, RAM 8GB, SSD 512GB.'),
    _d('Laptop Lenovo ThinkPad', 'Komputer', 'LAB002', 'Available',
        'photo-1531297484001-80022131f5a1',
        'Laptop untuk praktikum jaringan dan basis data, RAM 16GB.'),
    _d('PC Desktop Core i5', 'Komputer', 'LAB003', 'Available',
        'photo-1587620962725-abab7fe55159',
        'Komputer desktop lengkap dengan monitor 22 inci.'),
    _d('Raspberry Pi 4', 'Komputer', 'LAB004', 'Borrowed',
        'photo-1555664424-778a1e5e1b48',
        'Mini komputer 4GB untuk proyek IoT dan server kecil.'),
    // Elektronik
    _d('Arduino Uno R3', 'Elektronik', 'LAB005', 'Available',
        'photo-1553406830-ef2513450d76',
        'Board mikrokontroler ATmega328P untuk praktikum IoT.'),
    _d('ESP32 DevKit', 'Elektronik', 'LAB006', 'Available',
        'photo-1597852074816-d933c7d2b988',
        'Mikrokontroler dengan WiFi dan Bluetooth bawaan.'),
    _d('Sensor Ultrasonik HC-SR04', 'Elektronik', 'LAB007', 'Available',
        'photo-1518770660439-4636190af475',
        'Sensor jarak 2-400 cm untuk robot dan pengukuran.'),
    _d('Proyektor Epson', 'Elektronik', 'LAB008', 'Borrowed',
        'photo-1478720568477-152d9b164e26',
        'Proyektor 3300 lumens untuk presentasi laboratorium.'),
    _d('Power Supply DC 30V', 'Elektronik', 'LAB009', 'Available',
        'photo-1581092160562-40aa08e78837',
        'Catu daya variabel 0-30V / 0-5A.'),
    _d('Servo Motor SG90', 'Elektronik', 'LAB010', 'Available',
        'photo-1555664424-778a1e5e1b48',
        'Motor servo mikro 180 derajat untuk proyek robotik.'),
    // Pengukuran
    _d('Multimeter Digital', 'Pengukuran', 'LAB011', 'Available',
        'photo-1581092160562-40aa08e78837',
        'Alat ukur tegangan, arus, dan hambatan.'),
    _d('Oscilloscope Digital', 'Pengukuran', 'LAB012', 'Available',
        'photo-1581092918056-0c4c3acd3789',
        'Osiloskop 2 kanal 100MHz untuk analisis sinyal.'),
    _d('Function Generator', 'Pengukuran', 'LAB013', 'Borrowed',
        'photo-1581092918056-0c4c3acd3789',
        'Pembangkit sinyal sinus, kotak, dan segitiga.'),
    _d('Clamp Meter', 'Pengukuran', 'LAB014', 'Available',
        'photo-1581092160562-40aa08e78837',
        'Pengukur arus AC/DC tanpa memutus rangkaian.'),
    _d('Jangka Sorong Digital', 'Pengukuran', 'LAB015', 'Available',
        'photo-1581092160562-40aa08e78837',
        'Ketelitian 0.01 mm untuk mengukur dimensi benda.'),
    // Optik
    _d('Mikroskop Binokuler', 'Optik', 'LAB016', 'Borrowed',
        'photo-1581093458791-9d42e3c5e3b4',
        'Mikroskop pembesaran 40x-1000x untuk pengamatan preparat.'),
    _d('Mikroskop Digital USB', 'Optik', 'LAB017', 'Available',
        'photo-1576086213369-97a306d36557',
        'Mikroskop kamera 1000x, terhubung ke laptop.'),
    _d('Lup Laboratorium', 'Optik', 'LAB018', 'Available',
        'photo-1581093458791-9d42e3c5e3b4',
        'Kaca pembesar 10x dengan lampu LED.'),
    // Jaringan
    _d('Router Mikrotik', 'Jaringan', 'LAB019', 'Available',
        'photo-1558494949-ef010cbdcc31',
        'Router untuk praktikum konfigurasi jaringan.'),
    _d('Switch 24 Port', 'Jaringan', 'LAB020', 'Available',
        'photo-1544197150-b99a580bb7a8',
        'Switch managed 24 port gigabit.'),
    _d('Access Point TP-Link', 'Jaringan', 'LAB021', 'Borrowed',
        'photo-1558494949-ef010cbdcc31',
        'Access point dual-band untuk praktikum WLAN.'),
    _d('Crimping Tool + LAN Tester', 'Jaringan', 'LAB022', 'Available',
        'photo-1558494949-ef010cbdcc31',
        'Satu set alat pembuat kabel UTP dan penguji kabel.'),
    // Perkakas
    _d('Solder Station', 'Perkakas', 'LAB023', 'Available',
        'photo-1504148455328-c376907d081c',
        'Solder 60W dengan pengatur suhu.'),
    _d('Bor Listrik', 'Perkakas', 'LAB024', 'Available',
        'photo-1504148455328-c376907d081c',
        'Bor tangan 500W dengan 13 mata bor.'),
    _d('Toolkit Elektronik', 'Perkakas', 'LAB025', 'Available',
        'photo-1504148455328-c376907d081c',
        'Obeng presisi, tang, dan pinset 45 pcs.'),
    // Komponen
    _d('Breadboard 830 Titik', 'Komponen', 'LAB026', 'Available',
        'photo-1518770660439-4636190af475',
        'Papan rangkaian percobaan tanpa solder.'),
    _d('Kit Resistor & LED', 'Komponen', 'LAB027', 'Available',
        'photo-1518770660439-4636190af475',
        'Paket 600 resistor dan 100 LED aneka warna.'),
    _d('Kabel Jumper Set', 'Komponen', 'LAB028', 'Available',
        'photo-1597852074816-d933c7d2b988',
        'Kabel jumper male-female 120 pcs.'),
    // Kimia
    _d('Gelas Ukur 250 ml', 'Kimia', 'LAB029', 'Available',
        'photo-1532094349884-543bc11b234d',
        'Gelas ukur borosilikat untuk praktikum kimia.'),
    _d('Timbangan Digital', 'Kimia', 'LAB030', 'Borrowed',
        'photo-1532094349884-543bc11b234d',
        'Neraca digital ketelitian 0.01 gram.'),
  ];

  static Map<String, String> _d(
    String name,
    String category,
    String code,
    String status,
    String photoId,
    String spec,
  ) {
    return {
      'item_name': name,
      'category': category,
      'code': code,
      'status': status,
      'image': '$_u$photoId?w=800',
      'spesification': spec,
    };
  }
}