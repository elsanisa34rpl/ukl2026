import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _search = TextEditingController();
  final PageController _bannerController = PageController(viewportFraction: 1);
  String _selectedCategory = 'Semua';
  int _bannerIndex = 0;

  @override
  void dispose() {
    _search.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<ItemModel>>(
        stream: _service.getItems(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final categories = items.map((e) => e.category).where((e) => e.isNotEmpty).toSet().toList()..sort();
          final query = _search.text.trim().toLowerCase();

          final filtered = items.where((item) {
            final matchesSearch = query.isEmpty ||
                item.itemName.toLowerCase().contains(query) ||
                item.code.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query);
            final matchesCategory = _selectedCategory == 'Semua' || item.category == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();

          final available = filtered.where((e) => e.status == 'Available').toList();
          final borrowed = filtered.where((e) => e.status == 'Borrowed').toList();

          return Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: snapshot.hasError
                    ? const Center(child: Text('Gagal memuat data inventaris. Periksa koneksi dan Firestore.'))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                        children: [
                          const SizedBox(height: 4),
                          _buildBanner(),
                          const SizedBox(height: 25),
                          _sectionTitle('Semua Data', trailing: '${items.length} alat'),
                          const SizedBox(height: 12),
                          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData)
                            const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
                          else if (filtered.isEmpty)
                            _emptyState('Data alat belum tersedia', 'Tambahkan inventaris melalui menu Inventaris.')
                          else
                            _horizontalItems(filtered),
                          const SizedBox(height: 25),
                          _sectionTitle('Kategori Peralatan'),
                          const SizedBox(height: 12),
                          _categoryList(categories, items),
                          const SizedBox(height: 25),
                          _sectionTitle('Available', icon: Icons.check_circle, color: AppColors.available, trailing: '${available.length} alat'),
                          const SizedBox(height: 12),
                          if (available.isEmpty)
                            _emptyState('Tidak ada alat tersedia', 'Coba pilih kategori lain atau periksa kembali nanti.')
                          else
                            _horizontalItems(available),
                          const SizedBox(height: 25),
                          _sectionTitle('Borrowed', icon: Icons.lock_clock, color: AppColors.borrowed, trailing: '${borrowed.length} alat'),
                          const SizedBox(height: 12),
                          if (borrowed.isEmpty)
                            _emptyState('Belum ada alat dipinjam', 'Semua alat sedang tersedia.')
                          else
                            _horizontalItems(borrowed),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 17),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari nama, kode, atau kategori...',
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final banners = [
      ('Pinjam Alat dengan Mudah', 'Kelola kebutuhan praktikum dalam satu aplikasi.', 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=1400'),
      ('Inventaris Lebih Teratur', 'Temukan alat laboratorium dengan cepat.', 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=1400'),
      ('Pantau Ketersediaan Alat', 'Informasi inventaris diperbarui secara real-time.', 'https://images.unsplash.com/photo-1581092795360-fd1ca04f0952?w=1400'),
      ('Dukung Kegiatan Praktikum', 'Semua perlengkapan lab lebih mudah dipantau.', 'https://images.unsplash.com/photo-1581092580497-e0d23cbdf1dc?w=1400'),
    ];

    return Column(
      children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(23),
                  color: AppColors.navy,
                  image: DecorationImage(
                    image: NetworkImage(banner.$3),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: .42), BlendMode.darken),
                    onError: (_, __) {},
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(banner.$1, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(banner.$2, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _bannerIndex == index ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: _bannerIndex == index ? AppColors.primary : AppColors.primary.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(10),
            ),
          )),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, {IconData? icon, Color? color, String? trailing}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color ?? AppColors.navy, size: 21),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold))),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(color: (color ?? AppColors.primary).withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
            child: Text(trailing, style: TextStyle(color: color ?? AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _horizontalItems(List<ItemModel> items) {
    return SizedBox(
      height: 235,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _itemCard(items[index]),
      ),
    );
  }

  Widget _itemCard(ItemModel item) {
    final isAvailable = item.status == 'Available';
    return Container(
      width: 178,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .055), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 122,
            width: double.infinity,
            child: item.image.isEmpty
                ? Container(color: const Color(0xFFF0ECEE), child: const Icon(Icons.devices_other, size: 42, color: AppColors.secondary))
                : Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF0ECEE), child: const Icon(Icons.image_not_supported_outlined, color: AppColors.secondary, size: 35)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 4),
                Text(item.code, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: (isAvailable ? AppColors.available : AppColors.borrowed).withValues(alpha: .13), borderRadius: BorderRadius.circular(18)),
                  child: Text(item.status, style: TextStyle(color: isAvailable ? AppColors.available : AppColors.borrowed, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryList(List<String> categories, List<ItemModel> items) {
    final labels = ['Semua', ...categories];
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final label = labels[index];
          final count = label == 'Semua' ? items.length : items.where((e) => e.category == label).length;
          final selected = _selectedCategory == label;
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _selectedCategory = label),
            child: Container(
              width: 112,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFEDF0) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: selected ? AppColors.primary.withValues(alpha: .35) : AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_categoryIcon(label), size: 25, color: AppColors.secondary),
                  const SizedBox(height: 7),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text)),
                  const SizedBox(height: 3),
                  Text('$count alat', style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final value = category.toLowerCase();
    if (value.contains('arduino') || value.contains('komponen')) return Icons.memory;
    if (value.contains('laptop') || value.contains('komputer') || value.contains('elektronik')) return Icons.laptop_mac;
    if (value.contains('mikroskop') || value.contains('optik')) return Icons.biotech;
    if (value.contains('multimeter') || value.contains('ukur')) return Icons.electrical_services;
    if (value.contains('oscilloscope') || value.contains('osiloskop')) return Icons.monitor_heart;
    if (value.contains('router') || value.contains('jaringan')) return Icons.router;
    if (value.contains('perkakas')) return Icons.handyman;
    return Icons.category_outlined;
  }

  Widget _emptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 32),
          const SizedBox(height: 9),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}
