import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'admin_home_page.dart';
import 'login_page.dart';
import 'main_shell.dart';

/// Menentukan halaman awal berdasarkan status login dan role.
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = auth.user;
    if (user == null) return const LoginPage();
    return user.isAdmin ? const AdminHomePage() : const MainShell();
  }
}
