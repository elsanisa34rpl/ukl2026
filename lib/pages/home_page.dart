import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/item_card.dart';
import 'item_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _search = TextEditingController();

  String _category = 'Semua';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<ItemModel>>(
        stream: _service.getItems(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          final filtered = items.where((item) {
            final query = _search.text.toLowerCase();

            final matchSearch =
                item.itemName.toLowerCase().contains(query) ||
                item.code.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query);

            final matchCategory =
                _category == 'Semua' || item.category == _category;

            return matchSearch && matchCategory;
          }).toList();

          final categories = ['Semua', ...items.map((e) => e.category).toSet()];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.navy],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -72,
                        right: -34,
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 62,
                        right: 56,
                        child: Icon(
                          Icons.science_outlined,
                          size: 96,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.16,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.biotech_rounded,
                                      color: Colors.white,
                                      size: 23,
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'LabTrack',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      Text(
                                        'INVENTARIS LABORATORIUM',
                                        style: TextStyle(
                                          color: Color(0xFFD8D5C9),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Temukan alat\nyang kamu butuhkan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  height: 1.18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                'Jelajahi koleksi alat laboratorium dengan mudah.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _search,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Cari nama, kode, atau kategori...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.primaryDark,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(17),
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _banner(),

                    const SizedBox(height: 16),

                    _stats(items),

                    const SizedBox(height: 22),

                    _title('Semua Alat'),

                    if (snapshot.hasError)
                      const Text('Gagal memuat data inventaris.')
                    else if (!snapshot.hasData)
                      const Center(child: CircularProgressIndicator())
                    else if (filtered.isEmpty)
                      const Text('Belum ada alat yang sesuai.')
                    else
                      SizedBox(
                        height: 230,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailPage(item: item),
                                  ),
                                );
                              },
                              child: ItemCard(item: item),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 22),

                    _title('Kategori Peralatan'),

                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          final count = category == 'Semua'
                              ? items.length
                              : items
                                    .where((e) => e.category == category)
                                    .length;

                          return _categoryCard(
                            category,
                            count,
                            category == _category,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    _sectionWithItems(
                      'Available',
                      items.where((e) => e.status == 'Available').toList(),
                      AppColors.available,
                      Icons.check_circle,
                    ),

                    const SizedBox(height: 22),

                    _sectionWithItems(
                      'Borrowed',
                      items.where((e) => e.status == 'Borrowed').toList(),
                      AppColors.borrowed,
                      Icons.lock_clock,
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _banner() {
    return Container(
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1581093458791-9d42e3c5e3b4?w=1200',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
          ),
        ),
        child: const Text(
          'Pinjam Alat dengan Mudah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _stats(List<ItemModel> items) {
    final available = items.where((e) => e.status == 'Available').length;

    Widget cell(String value, String label, Color color, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        cell(
          '${items.length}',
          'Total Alat',
          AppColors.navy,
          Icons.inventory_2,
        ),
        const SizedBox(width: 10),
        cell('$available', 'Tersedia', AppColors.available, Icons.check_circle),
        const SizedBox(width: 10),
        cell(
          '${items.length - available}',
          'Dipinjam',
          AppColors.borrowed,
          Icons.lock_clock,
        ),
      ],
    );
  }

  Widget _title(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
      ),
    );
  }

  Widget _categoryCard(String category, int count, bool selected) {
    final icons = {
      'Semua': Icons.grid_view_rounded,
      'Komputer': Icons.laptop_mac,
      'Elektronik': Icons.memory,
      'Pengukuran': Icons.electrical_services,
      'Optik': Icons.biotech,
      'Jaringan': Icons.router,
      'Perkakas': Icons.handyman,
      'Komponen': Icons.developer_board,
      'Kimia': Icons.science,
    };

    return GestureDetector(
      onTap: () {
        setState(() => _category = category);
      },
      child: Container(
        width: 112,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFDECEF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons[category] ?? Icons.devices_other,
              color: AppColors.secondary,
              size: 25,
            ),
            const SizedBox(height: 7),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              '$count alat',
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionWithItems(
    String title,
    List<ItemModel> items,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 9),
            Expanded(child: _title(title)),
            Text(
              '${items.length} alat',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (items.isEmpty)
          const Text(
            'Belum ada data.',
            style: TextStyle(color: AppColors.muted),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailPage(item: item),
                      ),
                    );
                  },
                  child: ItemCard(item: item),
                );
              },
            ),
          ),
      ],
    );
  }
}
