import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/item_image.dart';
import '../widgets/status_badge.dart';
import 'item_detail_page.dart';
import 'item_form_page.dart';

class InventoryPage extends StatefulWidget {
  final bool embedded;

  const InventoryPage({super.key, this.embedded = false});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _search = TextEditingController();

  // Stream dibuat sekali agar tidak membuka listener baru tiap rebuild.
  late final Stream<List<ItemModel>> _stream = _service.getItems();

  String _status = 'Semua'; // Semua | Available | Borrowed

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _delete(ItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Alat'),
        content: Text('Yakin ingin menghapus ${item.itemName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteItem(item.id);
      if (!mounted) return;
      _snack('${item.itemName} berhasil dihapus.');
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal menghapus: $e');
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Inventaris'),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ItemFormPage(legacy: true)),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alat'),
      ),
      body: StreamBuilder<List<ItemModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _message(
              Icons.cloud_off,
              'Gagal mengambil data inventaris.',
              'Periksa koneksi internet dan aturan Firestore.',
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data!;
          final query = _search.text.trim().toLowerCase();

          final items = all.where((item) {
            final matchStatus = _status == 'Semua' || item.status == _status;
            final matchQuery =
                query.isEmpty ||
                item.itemName.toLowerCase().contains(query) ||
                item.code.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query);
            return matchStatus && matchQuery;
          }).toList();

          final available = all.where((e) => e.status == 'Available').length;

          return Column(
            children: [
              Container(
                color: AppColors.navy,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, kode, atau kategori...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    _chip('Semua', 'Semua (${all.length})'),
                    _chip('Available', 'Tersedia ($available)'),
                    _chip('Borrowed', 'Dipinjam (${all.length - available})'),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? _message(
                        Icons.inventory_2_outlined,
                        all.isEmpty
                            ? 'Belum ada data inventaris.'
                            : 'Tidak ada alat yang cocok.',
                        all.isEmpty
                            ? 'Tekan "Tambah Alat" untuk menambahkan.'
                            : 'Coba ubah kata kunci atau filter.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            _tile(context, items[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String value, String label) {
    final selected = _status == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        onSelected: (_) => setState(() => _status = value),
      ),
    );
  }

  Widget _tile(BuildContext context, ItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: ItemImage(item: item, width: 80, height: 80),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.code} • ${item.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StatusBadge(status: item.status, small: true),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.muted),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ItemFormPage(legacy: true, legacyItem: item),
                        ),
                      );
                    } else {
                      _delete(item);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          'Hapus',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _message(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.primaryDark),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}
