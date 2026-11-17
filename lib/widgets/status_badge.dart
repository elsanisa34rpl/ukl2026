import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final isAvailable = status == 'Available';
    final color = isAvailable ? AppColors.available : AppColors.borrowed;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 9 : 12,
        vertical: small ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAvailable ? 'Tersedia' : 'Dipinjam',
        style: TextStyle(
          color: color,
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
