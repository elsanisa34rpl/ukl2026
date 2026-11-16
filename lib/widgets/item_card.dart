import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../utils/app_colors.dart';
import '../pages/item_form_page.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final bool showActions;

  const ItemCard({super.key, required this.item, this.showActions = false});

  @override
  Widget build(BuildContext context) {
    final isAvailable = item.status == 'Available';
    final statusColor = isAvailable ? AppColors.available : AppColors.borrowed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .045), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: item.image.isEmpty
                  ? Container(width: 82, height: 82, color: const Color(0xFFFFF1F3), child: const Icon(Icons.devices_other, color: AppColors.secondary, size: 34))
                  : Image.network(
                      item.image,
                      width: 82,
                      height: 82,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 82, height: 82, color: const Color(0xFFFFF1F3), child: const Icon(Icons.image_not_supported_outlined, color: AppColors.secondary)),
                    ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text)),
                  const SizedBox(height: 5),
                  Text('${item.category} • ${item.code}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
                    child: Text(item.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            if (showActions)
              IconButton(
                tooltip: 'Edit alat',
                icon: const Icon(Icons.edit_outlined, color: AppColors.primaryDark),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemFormPage(item: item))),
              ),
          ],
        ),
      ),
    );
  }
}
