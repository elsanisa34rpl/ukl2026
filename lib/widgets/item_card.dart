
import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../utils/app_colors.dart';
import '../pages/item_form_page.dart';

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
    final isAvailable = item.status == 'Available';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: item.image.isEmpty
                  ? Container(
                      width: 88,
                      height: 88,
                      color: AppColors.background,
                      child: const Icon(
                        Icons.devices_other,
                        size: 35,
                      ),
                    )
                  : Image.network(
                      item.image,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          width: 88,
                          height: 88,
                          color: AppColors.background,
                          child: const Icon(
                            Icons.image_not_supported,
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.navy,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${item.category} • ${item.code}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (isAvailable
                              ? AppColors.available
                              : AppColors.borrowed)
                          .withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        color: isAvailable
                            ? AppColors.available
                            : AppColors.borrowed,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (showActions)
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                ),
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
      ),
    );
  }
}
