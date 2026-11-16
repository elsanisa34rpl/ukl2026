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
            final matches = item.itemName.toLowerCase().contains(query) ||
                item.code.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query);
            return matches && (_category == 'Semua' || item.category == _category);
          }).toList();
          final available = items.where((e) => e.status == 'Available').length;
          final borrowed = items.length - available;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: AppColors.navy,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.science_rounded, color: Color(0xFFF7E7D6), size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('LABTRACK', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.8, color: AppColors.navy)),
                                  Text('Laboratory management', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.notifications_none_rounded, color: AppColors.navy, size: 21),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('GOOD DAY, EXPLORER', style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        const SizedBox(height: 7),
                        const Text('Kelola lab dengan\nlebih terorganisir.', style: TextStyle(fontSize: 27, height: 1.12, fontWeight: FontWeight.w900, color: AppColors.navy, letterSpacing: -.7)),
                        const SizedBox(height: 17),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: SizedBox(
                            height: 178,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  'https://images.unsplash.com/photo-1581093458791-9d42e3c7b7a5?w=1200&auto=format&fit=crop',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: AppColors.secondary),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.navy.withValues(alpha: .94), AppColors.navy.withValues(alpha: .12)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
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
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(color: const Color(0xFFE8B18F), borderRadius: BorderRadius.circular(30)),
                                        child: const Text('SMART LAB SPACE', style: TextStyle(color: AppColors.navy, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text('Semua alat,\nsatu kendali.', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.12, fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 8),
                                      const Text('Pantau inventaris dan peminjaman\nlebih praktis setiap hari.', style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
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
                            hintText: 'Cari nama alat, kode, kategori...',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () { _search.clear(); setState(() {}); }),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _statCard('TOTAL ALAT', items.length.toString(), Icons.widgets_rounded, AppColors.navy),
                            const SizedBox(width: 9),
                            _statCard('TERSEDIA', available.toString(), Icons.check_circle_rounded, AppColors.available),
                            const SizedBox(width: 9),
                            _statCard('DIPINJAM', borrowed.toString(), Icons.schedule_rounded, AppColors.borrowed),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 13),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Kategori alat', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.navy))),
                      Text('${categoryList.length} kategori', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 91,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = category == _category;
                      final count = category == 'Semua' ? items.length : items.where((e) => e.category == category).length;
                      return GestureDetector(
                        onTap: () => setState(() => _category = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 116,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.navy : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: selected ? AppColors.navy : AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_categoryIcon(category), color: selected ? const Color(0xFFE8B18F) : AppColors.primary, size: 20),
                              const SizedBox(height: 6),
                              Text(category, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.navy)),
                              Text('$count barang', style: TextStyle(fontSize: 10, color: selected ? Colors.white60 : AppColors.muted)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 13),
                  child: Row(
                    children: [
                      Expanded(child: Text(_category == 'Semua' ? 'Semua inventaris' : _category, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.navy))),
                      Text('${visible.length} barang', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
              if (snapshot.hasError)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(25), child: Text('Gagal memuat inventaris. Periksa koneksi dan Firebase.')))
              else if (!snapshot.hasData)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(35), child: Center(child: CircularProgressIndicator(color: AppColors.primary))))
              else if (visible.isEmpty)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Belum ada barang pada kategori ini.', style: TextStyle(color: AppColors.muted)))))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 32),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ItemCard(item: visible[index]),
                      childCount: visible.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      mainAxisExtent: 265,
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
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppColors.navy)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, letterSpacing: .6, fontWeight: FontWeight.w800, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final value = category.toLowerCase();
    if (value.contains('elektronik') || value.contains('komponen')) return Icons.memory_rounded;
    if (value.contains('optik')) return Icons.biotech_rounded;
    if (value.contains('ukur')) return Icons.straighten_rounded;
    if (value.contains('jaringan')) return Icons.router_rounded;
    if (value.contains('audio') || value.contains('kamera')) return Icons.videocam_rounded;
    if (value.contains('perkakas')) return Icons.handyman_rounded;
    return Icons.grid_view_rounded;
  }
}