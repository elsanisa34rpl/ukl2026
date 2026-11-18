import 'package:flutter/material.dart';

import '../models/borrowing_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class AdminLoansPage extends StatelessWidget {
  final bool embedded;

  const AdminLoansPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: embedded ? null : AppBar(title: const Text('Riwayat Peminjaman')),
      body: StreamBuilder<List<BorrowingModel>>(
        stream: FirestoreService().watchAllBorrowings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil riwayat peminjaman.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final borrowings = snapshot.data!;
          if (borrowings.isEmpty) {
            return const Center(child: Text('Belum ada peminjaman.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: borrowings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final borrowing = borrowings[index];
              final active = borrowing.isActive;
              return Card(
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    borrowing.itemName,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      'Peminjam: ${borrowing.userName}\n'
                      'Dipinjam: ${_formatDate(borrowing.borrowDate?.toDate())}'
                      '${active ? '' : '\nDikembalikan: ${_formatDate(borrowing.returnDate?.toDate())}'}',
                    ),
                  ),
                  trailing: Chip(
                    label: Text(active ? 'Dipinjam' : 'Dikembalikan'),
                    backgroundColor: active
                        ? AppColors.borrowed.withValues(alpha: 0.15)
                        : AppColors.available.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: active ? AppColors.borrowed : AppColors.available,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Memproses...';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
  }
}
