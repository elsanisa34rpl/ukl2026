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

  String get _fallbackUrl {
    final value = '${item.itemName} ${item.category}'.toLowerCase();
    if (value.contains('laptop') || value.contains('notebook') || value.contains('komputer') || value.contains('pc')) {
      return 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=900&auto=format&fit=crop';
    }
    if (value.contains('mikroskop') || value.contains('optik')) {
      return 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=900&auto=format&fit=crop';
    }
    if (value.contains('arduino') || value.contains('breadboard') || value.contains('komponen') || value.contains('elektronik') || value.contains('pcb')) {
      return 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=900&auto=format&fit=crop';
    }
    if (value.contains('proyektor') || value.contains('projector')) {
      return 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=900&auto=format&fit=crop';
    }
    if (value.contains('speaker') || value.contains('audio') || value.contains('headset') || value.contains('mic')) {
      return 'https://images.unsplash.com/photo-1593078166038-9b6c4b0e5f2d?w=900&auto=format&fit=crop';
    }
    if (value.contains('router') || value.contains('jaringan') || value.contains('switch') || value.contains('kabel')) {
      return 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=900&auto=format&fit=crop';
    }
    if (value.contains('multimeter') || value.contains('ukur') || value.contains('meter') || value.contains('tang')) {
      return 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=900&auto=format&fit=crop';
    }
    if (value.contains('kamera') || value.contains('webcam')) {
      return 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=900&auto=format&fit=crop';
    }
    if (value.contains('printer')) {
      return 'https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?w=900&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=900&auto=format&fit=crop';
  }

  @override
  Widget build(BuildContext context) {
    final url = item.image.trim();
    if (url.isEmpty) return _networkImage(_fallbackUrl, isFallback: true);
    return _networkImage(url, isFallback: false);
  }

  Widget _networkImage(String url, {required bool isFallback}) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFEDE7DC),
            alignment: Alignment.center,
            child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (!isFallback) return _networkImage(_fallbackUrl, isFallback: true);
          return _placeholder();
        },
      ),
    );
  }

  Widget _placeholder() {
    final value = '${item.itemName} ${item.category}'.toLowerCase();
    IconData icon = Icons.inventory_2_outlined;
    if (value.contains('laptop') || value.contains('komputer')) icon = Icons.laptop_mac_rounded;
    else if (value.contains('mikroskop') || value.contains('optik')) icon = Icons.biotech_rounded;
    else if (value.contains('ukur') || value.contains('meter')) icon = Icons.straighten_rounded;
    else if (value.contains('jaringan') || value.contains('router')) icon = Icons.router_rounded;
    else if (value.contains('proyektor') || value.contains('audio')) icon = Icons.videocam_rounded;
    else if (value.contains('arduino') || value.contains('komponen')) icon = Icons.memory_rounded;

    return Container(
      width: width,
      height: height,
      color: const Color(0xFFEDE7DC),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary.withValues(alpha: .8), size: 42),
          const SizedBox(height: 7),
          const Text('Foto belum tersedia', style: TextStyle(fontSize: 10, color: AppColors.muted)),
        ],
      ),
    );
  }
}