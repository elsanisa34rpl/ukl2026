import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_exception.dart';
import '../models/loan.dart';
import '../providers/auth_provider.dart';
import '../repositoris/loan_repository.dart';
import '../utils/format.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  Future<void> _giveBack(BuildContext context, Loan loan) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = context.read<LoanRepository>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kembalikan barang?'),
        content: Text('Kembalikan "${loan.itemTitle}" sekarang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kembalikan'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await repo.giveBack(loan);
      messenger.showSnackBar(
        SnackBar(content: Text('"${loan.itemTitle}" sudah dikembalikan.')),
      );
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal mengembalikan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user!.uid;
    final repo = context.read<LoanRepository>();

    return StreamBuilder<List<Loan>>(
      stream: repo.watchByUser(uid),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final loans = snap.data!;
        if (loans.isEmpty) {
          return const Center(child: Text('Belum ada riwayat peminjaman.'));
        }
        final active = loans.where((l) => l.isActive).length;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sedang dipinjam: $active',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: loans.length,
                itemBuilder: (_, i) {
                  final l = loans[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l.itemTitle,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  l.isActive ? 'Dipinjam' : 'Dikembalikan',
                                ),
                              ),
                            ],
                          ),
                          Text('Dipinjam: ${formatDate(l.borrowedAt)}'),
                          if (l.returnedAt != null)
                            Text('Dikembalikan: ${formatDate(l.returnedAt!)}'),
                          if (l.isActive) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.tonalIcon(
                                icon: const Icon(Icons.assignment_return),
                                label: const Text('Kembalikan'),
                                onPressed: () => _giveBack(context, l),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
