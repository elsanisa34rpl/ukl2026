import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Pengguna belum login.')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat informasi akun.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() ?? {};
          final name = (data['name'] ?? user.displayName ?? 'Pengguna LabTrack').toString();
          final email = (data['email'] ?? user.email ?? '-').toString();
          final kelas = (data['kelas'] ?? '-').toString();
          final foto = (data['foto'] ?? '').toString();
          final initials = name.trim().isEmpty ? 'LT' : name.trim().split(RegExp(r'\\s+')).take(2).map((e) => e[0].toUpperCase()).join();

          return Column(
            children: [
              Container(
                height: 62,
                width: double.infinity,
                color: AppColors.navy,
                alignment: Alignment.center,
                child: const Text('Profil', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 26),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 25),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 47,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 43,
                              backgroundColor: Colors.white.withValues(alpha: .2),
                              backgroundImage: foto.isNotEmpty ? NetworkImage(foto) : null,
                              child: foto.isEmpty ? Text(initials, style: const TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w600)) : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.school, color: AppColors.secondary, size: 16),
                                const SizedBox(width: 7),
                                Text(kelas, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.fromLTRB(17, 18, 17, 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .035), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Informasi Akun', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 10),
                          _infoRow(Icons.person_outline, 'Nama', name),
                          _infoRow(Icons.school_outlined, 'Kelas', kelas),
                          _infoRow(Icons.mail_outline, 'Email', email, last: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('borrowings').orderBy('borrow_date', descending: true).snapshots(),
                      builder: (context, borrowingSnapshot) {
                        final docs = borrowingSnapshot.data?.docs ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(child: Text('Sedang Dipinjam', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 17))),
                                _countBadge('${docs.length} alat'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (borrowingSnapshot.hasError)
                              const Padding(padding: EdgeInsets.all(20), child: Text('Data peminjaman belum dapat dimuat.'))
                            else if (borrowingSnapshot.connectionState == ConnectionState.waiting && !borrowingSnapshot.hasData)
                              const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
                            else if (docs.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 15),
                                child: const Column(
                                  children: [
                                    Icon(Icons.inventory_2_outlined, color: AppColors.primaryDark, size: 48),
                                    SizedBox(height: 10),
                                    Text('Tidak ada alat yang sedang dipinjam', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                                  ],
                                ),
                              )
                            else
                              ...docs.map((doc) => Container(
                                margin: const EdgeInsets.only(bottom: 9),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [
                                    const CircleAvatar(backgroundColor: Color(0xFFFFEDF0), child: Icon(Icons.science_outlined, color: AppColors.primaryDark)),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text((doc.data()['item_name'] ?? 'Alat laboratorium').toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text))),
                                  ],
                                ),
                              )),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: AppColors.primaryDark),
                      label: const Text('Keluar', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(49),
                        side: const BorderSide(color: AppColors.primaryDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFFFF5F6), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primaryDark, size: 20)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            const SizedBox(height: 3),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
          ])),
        ],
      ),
    );
  }

  Widget _countBadge(String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFFFFE9EE), borderRadius: BorderRadius.circular(20)),
    child: Text(value, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 11)),
  );

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun LabTrack?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService().logout();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
    }
  }
}
