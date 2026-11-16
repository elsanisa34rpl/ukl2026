import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../utils/app_colors.dart';

class ItemImage extends StatelessWidget {
  final ItemModel item;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ItemImage({
    super.key,
    required this.item,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  static const _fallbackImages = {
    'laptop':
        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800',
    'mikroskop':
        'https://images.unsplash.com/photo-1581093458791-9d42e3c5e3b4?w=800',
    'elektronik':
        'https://images.unsplash.com/photo-1553406830-ef2513450d76?w=800',
    'pengukuran':
        'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800',
    'projector':
        'https://images.unsplash.com/photo-1528395874238-34d7b4f8c5?w=800',
  };

  String get _fallbackImage {
    final details = '${item.itemName} ${item.category}'.toLowerCase();

    if (details.contains('laptop')) return _fallbackImages['laptop']!;
    if (details.contains('mikroskop') || details.contains('optik')) {
      return _fallbackImages['mikroskop']!;
    }
    if (details.contains('projector') || details.contains('proyektor')) {
      return _fallbackImages['projector']!;
    }
    if (details.contains('multimeter') || details.contains('pengukuran')) {
      return _fallbackImages['pengukuran']!;
    }
    if (details.contains('elektronik') ||
        details.contains('arduino') ||
        details.contains('breadboard')) {
      return _fallbackImages['elektronik']!;
    }

    return _fallbackImages['pengukuran']!;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.image.trim();
    final fallbackImage = _fallbackImage;

    return SizedBox(
      width: width,
      height: height,
      child: imageUrl.isEmpty
          ? _networkImage(fallbackImage, fallbackImage)
          : _networkImage(imageUrl, fallbackImage),
    );
  }

  Widget _networkImage(String imageUrl, String fallbackImage) {
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (imageUrl != fallbackImage) {
          return _networkImage(fallbackImage, fallbackImage);
        }
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    final details = '${item.itemName} ${item.category}'.toLowerCase();
    final icon = details.contains('laptop')
        ? Icons.laptop_mac
        : details.contains('mikroskop') || details.contains('optik')
        ? Icons.biotech
        : details.contains('projector') || details.contains('proyektor')
        ? Icons.videocam
        : details.contains('multimeter') || details.contains('pengukuran')
        ? Icons.electrical_services
        : details.contains('arduino') || details.contains('elektronik')
        ? Icons.memory
        : Icons.devices_other;

    return Container(
      width: width,
      height: height,
      color: const Color(0xFFFDECEF),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.primary, size: 38),
    );
  }
}
