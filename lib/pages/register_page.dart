import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as app_auth;
import '../utils/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _kelas = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _kelas.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<app_auth.AuthProvider>().register(
        _name.text,
        _kelas.text,
        _email.text,
        _password.text,
      );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'email-already-in-use'
          ? 'Email sudah terdaftar.'
          : 'Pendaftaran gagal (${e.code}).';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gabung dengan LabTrack',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Buat akun pengguna untuk meminjam alat laboratorium.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 25),
                    _field(
                      'Nama lengkap',
                      _name,
                      Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama wajib diisi.'
                          : null,
                    ),
                    _field(
                      'Kelas',
                      _kelas,
                      Icons.school_outlined,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Kelas wajib diisi.'
                          : null,
                    ),
                    _field(
                      'Email',
                      _email,
                      Icons.email_outlined,
                      type: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Masukkan email yang valid.'
                          : null,
                    ),
                    const Text(
                      'Password',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        hintText: 'Minimal 6 karakter',
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Password minimal 6 karakter.'
                          : null,
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _busy
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Daftar Sekarang'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType type = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              hintText: 'Masukkan $label',
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
