import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import 'home_page.dart';
import 'inventory_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Mengisi data dummy ke Firestore hanya jika koleksi items masih kosong.
    FirestoreService().seedDummyItems().catchError((_) {});
  }

  final List<Widget> _pages = const [
    HomePage(),
    InventoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.10),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home,
              color: AppColors.primary,
            ),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(
              Icons.inventory_2,
              color: AppColors.primary,
            ),
            label: 'Inventaris',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: AppColors.primary,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}