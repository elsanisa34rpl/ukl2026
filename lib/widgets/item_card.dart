import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../utils/app_colors.dart';
import '../pages/item_form_page.dart';
import '../pages/item_detail_page.dart';
import 'item_image.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final bool showActions;

  const ItemCard({super.key, required this.item, this.showActions = false});

  @override
  Widget build(BuildContext context) {
    final available = item.status == 'Available';
    final statusColor = available ? AppColors.available : AppColors.borrowed;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailPage(item: item))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ItemImage(item: item, width: double.infinity, fit: BoxFit.cover),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFF7F3EC).withValues(alpha: .96), borderRadius: BorderRadius.circular(30)),
                        child: Text(item.category, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.navy)),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(30)),
                        child: Text(available ? 'Tersedia' : 'Dipinjam', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    if (showActions)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.primary),
                            onPressed: available ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemFormPage(item: item))) : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.navy)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 13, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(child: Text(item.code, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: .3))),
                        const Icon(Icons.arrow_outward_rounded, size: 15, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}