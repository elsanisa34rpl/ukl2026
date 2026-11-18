import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_exception.dart';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../repositoris/item_repository.dart';
import '../repositoris/loan_repository.dart';

class CatalogTab extends StatefulWidget {
  const CatalogTab({super.key});

  @override
  State<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  String _query = '';

  Future<void> _borrow(Item item) async {
    final messenger = ScaffoldMessenger.of(context);
    final user = context.read<AuthProvider>().user!;
    final repo = context.read<LoanRepository>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pinjam barang?'),
        content: Text('Kamu akan meminjam "${item.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pinjam'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await repo.borrow(item: item, user: user);
      messenger.showSnackBar(
        SnackBar(content: Text('"${item.title}" berhasil dipinjam.')),
      );
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal meminjam: $e')));
    }
  }

  void _showDetail(Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 16),
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(item.category)),
                Chip(label: Text('Tersedia ${item.available}/${item.total}')),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(item.available > 0 ? 'Pinjam' : 'Stok habis'),
                onPressed: item.available > 0
                    ? () {
                        Navigator.pop(sheetContext);
                        _borrow(item);
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ItemRepository>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari barang...',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Item>>(
            stream: repo.watchAll(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(child: Text('Terjadi kesalahan: ${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snap.data!
                  .where(
                    (i) =>
                        i.title.toLowerCase().contains(_query) ||
                        i.category.toLowerCase().contains(_query),
                  )
                  .toList();
              if (items.isEmpty) {
                return const Center(child: Text('Barang tidak ditemukan.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  final out = item.available < 1;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      onTap: () => _showDetail(item),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: item.imageUrl.isEmpty
                              ? const ColoredBox(
                                  color: Color(0xFFE0E0E0),
                                  child: Icon(Icons.inventory_2_outlined),
                                )
                              : Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const ColoredBox(
                                    color: Color(0xFFE0E0E0),
                                    child: Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                        ),
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.category} • ${out ? "Stok habis" : "Tersedia ${item.available}/${item.total}"}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
