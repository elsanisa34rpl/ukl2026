
import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/item_card.dart';
import 'item_form_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventaris Alat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        backgroundColor: AppColors.background,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ItemFormPage(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alat'),
      ),

      body: StreamBuilder<List<ItemModel>>(
        stream: service.getItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 65,
                      color: AppColors.muted,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Belum ada data inventaris.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Tambahkan data contoh ke Firestore untuk memulai.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await service.seedDummyItems();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Data dummy berhasil ditambahkan.',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Isi Data Dummy'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
            children: [
              Text(
                '${items.length} alat terdaftar di database',
                style: const TextStyle(
                  color: AppColors.muted,
                ),
              ),

              const SizedBox(height: 14),

              ...items.map(
                (item) => Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,

                  background: Container(
                    margin: const EdgeInsets.only(bottom: 13),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 22),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),

                  confirmDismiss: (_) async {
                    return await _confirmDelete(context);
                  },

                  onDismissed: (_) async {
                    await service.deleteItem(item.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data alat berhasil dihapus.'),
                        ),
                      );
                    }
                  },

                  child: ItemCard(
                    item: item,
                    showActions: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus inventaris?'),
            content: const Text(
              'Data alat yang dihapus tidak dapat dikembalikan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
