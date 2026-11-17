import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../utils/app_colors.dart';

/// Menampilkan gambar alat dari URL. Jika URL kosong atau gagal dimuat,
/// dicoba gambar cadangan sesuai kategori, lalu ikon sebagai terakhir.
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

  static const _base = 'https://images.unsplash.com/';

  static const _fallbackByCategory = {
    'komputer': '${_base}photo-1496181133206-80ce9b88a853?w=800',
    'elektronik': '${_base}photo-1553406830-ef2513450d76?w=800',
    'pengukuran': '${_base}photo-1581092160562-40aa08e78837?w=800',
    'mikroskop':
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/50/Microscope_MET_DP108688.jpg/960px-Microscope_MET_DP108688.jpg',
    'microscope':
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/50/Microscope_MET_DP108688.jpg/960px-Microscope_MET_DP108688.jpg',
    'optik':
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/50/Microscope_MET_DP108688.jpg/960px-Microscope_MET_DP108688.jpg',
    'jaringan': '${_base}photo-1558494949-ef010cbdcc31?w=800',
    'komponen': '${_base}photo-1518770660439-4636190af475?w=800',
    'perkakas': '${_base}photo-1504148455328-c376907d081c?w=800',
    'kimia': '${_base}photo-1532094349884-543bc11b234d?w=800',
    'audio visual': '${_base}photo-1478720568477-152d9b164e26?w=800',
    'proyektor': '${_base}photo-1478720568477-152d9b164e26?w=800',
    'projector': '${_base}photo-1478720568477-152d9b164e26?w=800',
  };

  static const _defaultFallback =
      '${_base}photo-1532094349884-543bc11b234d?w=800';

  String get _fallbackImage {
    final details = '${item.category} ${item.itemName}'.toLowerCase();

    for (final entry in _fallbackByCategory.entries) {
      if (details.contains(entry.key)) return entry.value;
    }

    return _defaultFallback;
  }

  @override
  Widget build(BuildContext context) {
    final url = item.image.trim();
    final fallback = _fallbackImage;

    final first = url.isNotEmpty ? url : fallback;

    return SizedBox(
      width: width,
      height: height,
      child: _network(first, fallback),
    );
  }

  Widget _network(String url, String fallback) {
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFFDECEF),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (url != fallback) {
          return _network(fallback, fallback);
        }
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    final details = '${item.itemName} ${item.category}'.toLowerCase();
    final icon = details.contains('laptop') || details.contains('komputer')
        ? Icons.laptop_mac
        : details.contains('mikroskop') || details.contains('optik')
        ? Icons.biotech
        : details.contains('proyektor') || details.contains('projector')
        ? Icons.videocam
        : details.contains('ukur') || details.contains('meter')
        ? Icons.electrical_services
        : details.contains('jaringan') || details.contains('router')
        ? Icons.router
        : details.contains('kimia')
        ? Icons.science
        : details.contains('perkakas') || details.contains('solder')
        ? Icons.handyman
        : Icons.memory;

    return Container(
      width: width,
      height: height,
      color: const Color(0xFFFDECEF),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.primary, size: 38),
    );
  }
}
