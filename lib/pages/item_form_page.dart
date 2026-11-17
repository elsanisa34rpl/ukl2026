import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class ItemFormPage extends StatefulWidget {
  final ItemModel? item;
  const ItemFormPage({super.key, this.item});
  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _image = TextEditingController();
  final _spec = TextEditingController();
  final _service = FirestoreService();
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
  String? _category;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    final i = widget.item;
    if (i != null) {
      _name.text = i.itemName;
      _code.text = i.code;
      _image.text = i.image;
      _spec.text = i.spesification;
      _category = i.category;
    } else {
      _category = _categories.first;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _image.dispose();
    _spec.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final item = ItemModel(
        id: widget.item?.id ?? '',
        itemName: _name.text.trim(),
        category: _category!,
        code: _code.text.trim(),
        status: 'Available',
        image: _image.text.trim(),
        spesification: _spec.text.trim(),
      );
      if (widget.item == null) {
        await _service.addItem(item);
      } else {
        await _service.updateItem(item);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.item == null
                ? 'Barang berhasil ditambahkan.'
                : 'Perubahan berhasil disimpan.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.item != null;
    final borrowed = widget.item?.status == 'Borrowed';
    final cats = {..._categories, ?_category}.toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(edit ? 'Edit Barang' : 'Tambah Barang')),
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
              key: _key,
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
                        _field('Nama barang', _name, 'Contoh: Laptop ASUS'),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: cats
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _category = v),
                          validator: (v) =>
                              v == null ? 'Pilih kategori barang.' : null,
                        ),
                        const SizedBox(height: 16),
                        _field('Kode barang', _code, 'Contoh: LAB007'),
                        const SizedBox(height: 16),
                        _field(
                          'URL gambar (opsional)',
                          _image,
                          'https://...',
                          required: false,
                        ),
                        const SizedBox(height: 16),
                        _field(
                          'Spesifikasi',
                          _spec,
                          'Deskripsikan barang',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _save,
                      icon: _loading
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
                        edit ? 'Simpan Perubahan' : 'Tambahkan Barang',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c,
    String hint, {
    int maxLines = 1,
    bool required = true,
  }) => TextFormField(
    controller: c,
    maxLines: maxLines,
    decoration: InputDecoration(labelText: label, hintText: hint),
    validator: (v) {
      if (required && (v == null || v.trim().isEmpty)) {
        return '$label wajib diisi.';
      }
      if (label.startsWith('URL') &&
          v != null &&
          v.trim().isNotEmpty &&
          (Uri.tryParse(v.trim()) == null ||
              !['http', 'https'].contains(Uri.tryParse(v.trim())!.scheme) ||
              Uri.tryParse(v.trim())!.host.isEmpty)) {
        return 'URL gambar tidak valid.';
      }
      return null;
    },
  );
}
