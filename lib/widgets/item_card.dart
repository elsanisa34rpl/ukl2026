import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../utils/app_colors.dart';
import '../pages/item_form_page.dart';
import '../pages/item_detail_page.dart';
import 'item_image.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final bool showActions;

  const ItemCard({
    super.key,
    required this.item,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final available = item.status == 'Available';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailPage(item: item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: ItemImage(
                item: item,
                height: 115,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.code,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _statusBadge(available),
                  if (showActions)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemFormPage(item: item),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: available
            ? AppColors.available.withValues(alpha: 0.12)
            : AppColors.borrowed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: available
              ? AppColors.available
              : AppColors.borrowed,
        ),
      ),
    );
  }
}
