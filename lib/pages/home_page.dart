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
                _category == 'Semua' ||
                item.category == _category;

            return matchSearch && matchCategory;
          }).toList();

          final categories = [
            'Semua',
            ...items.map((e) => e.category).toSet(),
          ];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari nama, kode, atau kategori...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primaryDark,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _banner(),

                    const SizedBox(height: 23),

                    _title('Semua Data'),

                    if (snapshot.hasError)
                      const Text('Gagal memuat data inventaris.')
                    else if (!snapshot.hasData)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
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
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.65),
            ],
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

  Widget _categoryCard(
    String category,
    int count,
    bool selected,
  ) {
    final icons = {
      'Arduino': Icons.memory,
      'Laptop': Icons.laptop,
      'Mikroskop': Icons.biotech,
      'Multimeter': Icons.electrical_services,
      'Oscilloscope': Icons.settings_input_component,
      'Perkakas': Icons.handyman,
      'Router': Icons.router,
      'Semua': Icons.grid_view,
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              '$count alat',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.muted,
              ),
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
            Expanded(
              child: _title(title),
            ),
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
