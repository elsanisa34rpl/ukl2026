import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/item_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = FirestoreService();
  final _search = TextEditingController();
  String _category = 'Semua';

  @override
  void dispose() {
    _search.dispose();
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
          final categoryList = items.map((e) => e.category).toSet().toList()..sort();
          final categories = ['Semua', ...categoryList];
          final query = _search.text.trim().toLowerCase();
          final visible = items.where((item) {
            final matchesSearch = item.itemName.toLowerCase().contains(query) ||
                item.code.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query);
            return matchesSearch && (_category == 'Semua' || item.category == _category);
          }).toList();
          final available = items.where((e) => e.status == 'Available').length;
          final borrowed = items.length - available;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.science_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 11),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('LABTRACK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.navy)),
                                Text('Laboratory inventory system', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
                              child: const Icon(Icons.notifications_none_rounded, color: AppColors.navy),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 178,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF173A80), Color(0xFF287BC4), Color(0xFF22A9B7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -24,
                                  top: -16,
                                  bottom: -16,
                                  width: 190,
                                  child: Opacity(
                                    opacity: .34,
                                    child: Image.network(
                                      'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=700',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const SizedBox(),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(21),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(20)),
                                        child: const Text('PUSAT INVENTARIS LAB', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text('Kelola alat lab\nlebih mudah.', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.15, fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 8),
                                      const Text('Cari, pantau, dan pinjam peralatan\ndalam satu tempat.', style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Cari alat, kode, atau kategori...',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border.withValues(alpha: .7))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.3)),
                          ),
                        ),
                        const SizedBox(height: 17),
                        Row(
                          children: [
                            _statCard('Total inventaris', items.length.toString(), Icons.inventory_2_outlined, const Color(0xFF3157D5)),
                            const SizedBox(width: 10),
                            _statCard('Tersedia', available.toString(), Icons.check_circle_outline, const Color(0xFF15966B)),
                            const SizedBox(width: 10),
                            _statCard('Dipinjam', borrowed.toString(), Icons.assignment_outlined, const Color(0xFFE18A35)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(child: Text('Jelajahi kategori', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy))),
                      Text('${categoryList.length} kategori', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 92,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 9),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = category == _category;
                      final count = category == 'Semua' ? items.length : items.where((e) => e.category == category).length;
                      return GestureDetector(
                        onTap: () => setState(() => _category = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 112,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                            boxShadow: selected ? [BoxShadow(color: AppColors.primary.withValues(alpha: .18), blurRadius: 12, offset: const Offset(0, 5))] : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_categoryIcon(category), color: selected ? Colors.white : AppColors.primary, size: 20),
                              const SizedBox(height: 6),
                              Text(category, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? Colors.white : AppColors.navy)),
                              Text('$count barang', style: TextStyle(fontSize: 10, color: selected ? Colors.white70 : AppColors.muted)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: Text(_category == 'Semua' ? 'Inventaris terbaru' : 'Kategori $_category', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy))),
                      Text('${visible.length} barang', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
              if (snapshot.hasError)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(25), child: Text('Gagal memuat inventaris. Periksa koneksi dan Firebase.')))
              else if (!snapshot.hasData)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(35), child: Center(child: CircularProgressIndicator())))
              else if (visible.isEmpty)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Belum ada barang pada kategori ini.', style: TextStyle(color: AppColors.muted)))))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 3, 20, 30),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ItemCard(item: visible[index]),
                      childCount: visible.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      mainAxisExtent: 258,
                      crossAxisSpacing: 13,
                      mainAxisSpacing: 13,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withValues(alpha: .7))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.navy)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final value = category.toLowerCase();
    if (value.contains('elektronik')) return Icons.memory_rounded;
    if (value.contains('komponen')) return Icons.developer_board_rounded;
    if (value.contains('optik')) return Icons.biotech_rounded;
    if (value.contains('ukur')) return Icons.straighten_rounded;
    if (value.contains('jaringan')) return Icons.router_rounded;
    if (value.contains('audio')) return Icons.videocam_rounded;
    if (value.contains('perkakas')) return Icons.handyman_rounded;
    return Icons.grid_view_rounded;
  }
}
