
import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class ItemFormPage extends StatefulWidget {
  final ItemModel? item;

  const ItemFormPage({
    super.key,
    this.item,
  });

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _category = TextEditingController();
  final _code = TextEditingController();
  final _image = TextEditingController();
  final _specification = TextEditingController();

  String _status = 'Available';
  bool _loading = false;

  final _service = FirestoreService();

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    if (item != null) {
      _name.text = item.itemName;
      _category.text = item.category;
      _code.text = item.code;
      _image.text = item.image;
      _specification.text = item.spesification;
      _status = item.status;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _code.dispose();
    _image.dispose();
    _specification.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final item = ItemModel(
        id: widget.item?.id ?? '',
        itemName: _name.text.trim(),
        category: _category.text.trim(),
        code: _code.text.trim(),
        status: _status,
        image: _image.text.trim(),
        spesification: _specification.text.trim(),
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
                ? 'Alat berhasil ditambahkan.'
                : 'Data alat berhasil diperbarui.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Inventaris' : 'Tambah Inventaris',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        backgroundColor: AppColors.background,
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _input(
              'Nama alat',
              _name,
              'Contoh: Laptop ASUS',
            ),

            _input(
              'Kategori',
              _category,
              'Contoh: Elektronik',
            ),

            _input(
              'Kode alat',
              _code,
              'Contoh: LAB007',
            ),

            _input(
              'URL gambar',
              _image,
              'https://...',
            ),

            _input(
              'Spesifikasi',
              _specification,
              'Tuliskan spesifikasi alat',
              maxLines: 3,
            ),

            const Text(
              'Status alat',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.info_outline),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Available',
                  child: Text('Available'),
                ),
                DropdownMenuItem(
                  value: 'Borrowed',
                  child: Text('Borrowed'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value ?? 'Available';
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        isEdit
                            ? 'Simpan Perubahan'
                            : 'Tambah Alat',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label wajib diisi.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
