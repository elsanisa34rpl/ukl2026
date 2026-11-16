import 'package:flutter/material.dart';

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
  final List<Widget> _pages = const [HomePage(), InventoryPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: _selectedIndex == 0 ? AppColors.primary : AppColors.muted),
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, color: _selectedIndex == 1 ? AppColors.primary : AppColors.muted),
            selectedIcon: const Icon(Icons.inventory_2, color: AppColors.primary),
            label: 'Inventaris',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: _selectedIndex == 2 ? AppColors.primary : AppColors.muted),
            selectedIcon: const Icon(Icons.person, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
