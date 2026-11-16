
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/item_image.dart';

class ItemDetailPage extends StatefulWidget {
  final ItemModel item;

  const ItemDetailPage({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final FirestoreService _service = FirestoreService();

  bool _loading = false;

  Future<void> _borrowItem() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Silakan login terlebih dahulu.');
      return;
    }

    if (widget.item.status != 'Available') {
      _showMessage('Alat sedang dipinjam pengguna lain.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _service.borrowItem(
        uid: user.uid,
        item: widget.item,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alat berhasil dipinjam!'),
          backgroundColor: AppColors.available,
        ),
      );
    } catch (e) {
      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _copyCode() {
    Clipboard.setData(
      ClipboardData(text: widget.item.code),
    );
    _showMessage('Kode alat berhasil disalin.');
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '-';

    final date = timestamp.toDate();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'Mei', 'Jun', 'Jul', 'Agu',
      'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final available = item.status == 'Available';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // HEADER FOTO ALAT
          _buildHeader(),

          // KONTEN DETAIL
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              children: [
                // STATUS PEMINJAMAN
                _buildStatusBanner(available),

                const SizedBox(height: 17),

                // KODE DAN KATEGORI
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.qr_code,
                        title: 'Kode',
                        value: item.code,
                        trailing: IconButton(
                          onPressed: _copyCode,
                          icon: const Icon(
                            Icons.copy_outlined,
                            color: AppColors.muted,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.category_outlined,
                        title: 'Kategori',
                        value: item.category,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                // SPESIFIKASI
                _buildSectionCard(
                  title: 'Spesifikasi',
                  icon: Icons.subject,
                  child: Text(
                    item.spesification.isEmpty
                        ? 'Belum ada spesifikasi alat.'
                        : item.spesification,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 17),

                // INFORMASI
                _buildSectionCard(
                  title: 'Informasi',
                  icon: Icons.info_outline,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              color: AppColors.muted,
                            ),
                          ),
                          _buildStatusChip(item.status),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ditambahkan',
                            style: TextStyle(
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            _formatDate(item.createdAt),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 23),

                // ALAT SERUPA
                const Text(
                  'Alat Serupa',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),

                const SizedBox(height: 14),

                _buildSimilarItems(),
              ],
            ),
          ),

          // TOMBOL PEMINJAMAN DI BAGIAN BAWAH
          _buildBottomButton(available),
        ],
      ),
    );
  }

  // HEADER FOTO
  Widget _buildHeader() {
    final item = widget.item;

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ItemImage(
            item: item,
            fit: BoxFit.cover,
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .65),
                ],
              ),
            ),
          ),

          Positioned(
            top: 42,
            left: 18,
            child: CircleAvatar(
              backgroundColor:
                  AppColors.navy.withValues(alpha: .85),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            top: 42,
            right: 18,
            child: CircleAvatar(
              backgroundColor:
                  AppColors.navy.withValues(alpha: .85),
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog.fullscreen(
                      child: Stack(
                        children: [
                          Center(
                            child: InteractiveViewer(
                              child: ItemImage(
                                item: item,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 35,
                            right: 15,
                            child: IconButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Text(
              item.itemName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STATUS BANNER
  Widget _buildStatusBanner(bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: available
            ? AppColors.available
            : AppColors.borrowed,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Icon(
            available
                ? Icons.check_circle_outline
                : Icons.lock_clock_outlined,
            color: Colors.white,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              available
                  ? 'Alat tersedia untuk dipinjam'
                  : 'Sedang dipinjam pengguna lain',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // KARTU INFORMASI
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 75),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .045),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryDark,
            size: 23,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  // KARTU BAGIAN SPESIFIKASI DAN INFORMASI
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.secondary,
                size: 21,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final available = status == 'Available';
    final color = available
        ? AppColors.available
        : AppColors.borrowed;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ALAT SERUPA DARI FIRESTORE
  Widget _buildSimilarItems() {
    return StreamBuilder<List<ItemModel>>(
      stream: _service.getItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Gagal memuat alat serupa.');
        }

        if (!snapshot.hasData) {
          return const SizedBox(
            height: 90,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final similarItems = snapshot.data!
            .where(
              (element) =>
                  element.id != widget.item.id &&
                  element.category == widget.item.category,
            )
            .toList();

        if (similarItems.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Belum ada alat lain dalam kategori ini.',
              style: TextStyle(color: AppColors.muted),
            ),
          );
        }

        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: similarItems.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = similarItems[index];

              return InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemDetailPage(item: item),
                    ),
                  );
                },
                child: Container(
                  width: 178,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: ItemImage(
                          item: item,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(11),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.text,
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
                            _buildStatusChip(item.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // TOMBOL BAWAH
  Widget _buildBottomButton(bool available) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 13, 17, 17),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 49,
        child: ElevatedButton(
          onPressed: available && !_loading
              ? _borrowItem
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor:
                const Color(0xFFE5E5E8),
            foregroundColor: Colors.white,
            disabledForegroundColor:
                const Color(0xFF9999A2),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  height: 21,
                  width: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  available
                      ? 'Pinjam Alat'
                      : 'Sedang Dipinjam Pengguna Lain',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}
