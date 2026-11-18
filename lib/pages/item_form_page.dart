import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_exception.dart';
import '../models/item.dart';
import '../models/item_model.dart';
import '../repositoris/item_repository.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class ItemFormPage extends StatefulWidget {
  final Item? item; // null = tambah baru
  final ItemModel? legacyItem;
  final bool legacy;

  const ItemFormPage({
    super.key,
    this.item,
    this.legacyItem,
    this.legacy = false,
  });

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  static const _categories = [
    'Elektronik',
    'Komponen',
    'Optik',
    'Pengukuran',
    'Audio Visual',
    'Jaringan',
    'Perkakas',
    'Lainnya',
  ];

  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: widget.item?.title ?? widget.legacyItem?.itemName,
  );
  late final _desc = TextEditingController(
    text: widget.item?.description ?? widget.legacyItem?.spesification,
  );
  late final _category = TextEditingController(
    text: widget.item?.category ?? widget.legacyItem?.category,
  );
  late final _image = TextEditingController(
    text: widget.item?.imageUrl ?? widget.legacyItem?.image,
  );
  late final _code = TextEditingController(text: widget.legacyItem?.code ?? '');
  late final _total = TextEditingController(
    text: (widget.item?.total ?? 1).toString(),
  );
  String? _selectedCategory;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.legacyItem?.category ??
        widget.item?.category ??
        _categories.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _category.dispose();
    _image.dispose();
    _code.dispose();
    _total.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final editing = widget.item != null || widget.legacyItem != null;
    setState(() => _busy = true);
    try {
      if (widget.legacy) {
        final item = ItemModel(
          id: widget.legacyItem?.id ?? '',
          itemName: _title.text.trim(),
          category: _selectedCategory!,
          code: _code.text.trim(),
          status: widget.legacyItem?.status ?? 'Available',
          image: _image.text.trim(),
          spesification: _desc.text.trim(),
        );
        final service = FirestoreService();
        if (widget.legacyItem == null) {
          await service.addItem(item);
        } else {
          await service.updateItem(item);
        }
      } else {
        final repo = context.read<ItemRepository>();
        final total = int.parse(_total.text.trim());
        final item = Item(
          id: widget.item?.id ?? '',
          title: _title.text.trim(),
          description: _desc.text.trim(),
          category: _category.text.trim(),
          imageUrl: _image.text.trim(),
          total: total,
          available: widget.item?.available ?? total,
        );
        if (widget.item == null) {
          await repo.add(item);
        } else {
          await repo.update(item);
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editing
                ? 'Perubahan berhasil disimpan.'
                : 'Barang berhasil ditambahkan.',
          ),
        ),
      );
      Navigator.pop(context);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  String? _stock(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1) return 'Isi angka minimal 1';
    return null;
  }

  String? _imageUrl(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !const ['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return 'URL gambar tidak valid.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.item != null || widget.legacyItem != null;
    final borrowed = widget.legacyItem?.status == 'Borrowed';
    final categories = {..._categories, ?_selectedCategory}.toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(editing ? 'Edit Barang' : 'Tambah Barang')),
      body: borrowed
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Barang sedang dipinjam. Data tidak dapat diedit sampai barang tersedia kembali.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi barang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Lengkapi data agar barang mudah ditemukan.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: _title,
                          decoration: const InputDecoration(
                            labelText: 'Nama barang',
                            hintText: 'Contoh: Laptop ASUS',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        if (widget.legacy)
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                                _category.text = value ?? '';
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Pilih kategori barang.' : null,
                          )
                        else
                          TextFormField(
                            controller: _category,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            validator: _required,
                          ),
                        if (widget.legacy) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _code,
                            decoration: const InputDecoration(
                              labelText: 'Kode barang',
                              hintText: 'Contoh: LAB007',
                              prefixIcon: Icon(Icons.qr_code_2_outlined),
                            ),
                            validator: _required,
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _total,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah stok',
                              prefixIcon: Icon(Icons.numbers_outlined),
                            ),
                            validator: _stock,
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _image,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                            labelText: 'URL Gambar (opsional)',
                            hintText: 'https://...',
                            prefixIcon: Icon(Icons.image_outlined),
                          ),
                          validator: _imageUrl,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _desc,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            hintText: 'Deskripsikan barang',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: _required,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _save,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        editing ? 'Simpan Perubahan' : 'Tambahkan Barang',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
