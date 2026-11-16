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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailPage(item: item))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: .75)),
            boxShadow: [BoxShadow(color: const Color(0xFF1D3557).withValues(alpha: .045), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          clipBehavior: Clip.antiAlias,
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
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .94), borderRadius: BorderRadius.circular(20)),
                        child: Text(item.category, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.navy)),
                      ),
                    ),
                    if (showActions)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.white.withValues(alpha: .95),
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
                    Text(item.itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navy)),
                    const SizedBox(height: 4),
                    Text(item.code, style: const TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: .4)),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: available ? AppColors.available : AppColors.borrowed, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(available ? 'Tersedia' : 'Sedang dipinjam', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: available ? AppColors.available : AppColors.borrowed)),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.muted),
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
