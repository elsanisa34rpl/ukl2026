
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
  String _status = 'Semua';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<ItemModel>>(
          stream: _service.getItems(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];

            final filtered = items.where((item) {
              final searchMatch = item.itemName
                  .toLowerCase()
                  .contains(_search.text.toLowerCase());

              final categoryMatch =
                  _category == 'Semua' ||
                  item.category == _category;

              final statusMatch =
                  _status == 'Semua' ||
                  item.status == _status;

              return searchMatch &&
                  categoryMatch &&
                  statusMatch;
            }).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'LABORATORY APP',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Explore Equipment',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.biotech,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Cari nama alat inventaris...',
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 150,
                  child: PageView(
                    children: [
                      _banner(
                        'Manage Your Lab',
                        'Semua alat laboratorium dalam satu aplikasi.',
                        Icons.science,
                      ),
                      _banner(
                        'Find Equipment',
                        'Cari alat dengan cepat dan mudah.',
                        Icons.search_rounded,
                      ),
                      _banner(
                        'Stay Organized',
                        'Pantau ketersediaan inventaris secara real-time.',
                        Icons.inventory_2,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                _sectionTitle('Ringkasan Inventaris'),

                Row(
                  children: [
                    _statCard(
                      'Total Alat',
                      '${items.length}',
                      Icons.widgets_rounded,
                      AppColors.primary,
                    ),

                    const SizedBox(width: 10),

                    _statCard(
                      'Available',
                      '${items.where((e) => e.status == 'Available').length}',
                      Icons.check_circle_outline,
                      AppColors.available,
                    ),

                    const SizedBox(width: 10),

                    _statCard(
                      'Borrowed',
                      '${items.where((e) => e.status == 'Borrowed').length}',
                      Icons.access_time,
                      AppColors.borrowed,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _sectionTitle('Kategori Peralatan'),

                _chips(
                  ['Semua', 'Elektronik', 'Optik', 'Pengukuran', 'Komponen'],
                  _category,
                  (v) => setState(() => _category = v),
                ),

                const SizedBox(height: 18),

                _sectionTitle('Status Alat'),

                _chips(
                  ['Semua', 'Available', 'Borrowed'],
                  _status,
                  (v) => setState(() => _status = v),
                ),

                const SizedBox(height: 18),

                _sectionTitle('Semua Data'),

                if (snapshot.hasError)
                  const Text('Gagal mengambil data inventaris.')

                else if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    !snapshot.hasData)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: CircularProgressIndicator(),
                    ),
                  )

                else if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Belum ada alat yang cocok dengan pencarian.',
                    ),
                  )

                else
                  ...filtered
                      .take(5)
                      .map((item) => ItemCard(item: item)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _banner(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            icon,
            color: Colors.white70,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            Text(
              title,
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

  Widget _chips(
    List<String> values,
    String selected,
    Function(String) onTap,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: values.map((value) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(value),
              selected: selected == value,
              onSelected: (_) => onTap(value),
              selectedColor: AppColors.primary.withValues(alpha: .15),
              labelStyle: TextStyle(
                color: selected == value
                    ? AppColors.primary
                    : AppColors.text,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              backgroundColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
