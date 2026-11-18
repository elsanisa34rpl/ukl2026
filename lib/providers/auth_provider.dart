import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _sub;

  AppUser? user;
  bool loading = true;
  bool _registering = false;
  bool _checkingLogin = false;
  bool _roleRejectedSession = false;

  AuthProvider(this._service) {
    _sub = _service.authChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? fbUser) async {
    if (_registering || _checkingLogin) return;
    if (fbUser == null) {
      _roleRejectedSession = false;
      user = null;
    } else if (_roleRejectedSession) {
      return;
    } else {
      user = await _service.fetchProfile(fbUser.uid);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> login(
    String email,
    String password, {
    required UserRole expectedRole,
  }) async {
    _checkingLogin = true;
    _roleRejectedSession = false;
    try {
      final credential = await _service.login(email, password);
      final uid = credential.user?.uid;
      if (uid == null) {
        await _service.logout();
        throw StateError('Firebase tidak mengembalikan pengguna yang login.');
      }

      AppUser? profile;
      try {
        profile = await _service.fetchProfile(uid);
      } on FirebaseException catch (e) {
        await _service.logout();
        if (e.code == 'permission-denied') {
          throw const LoginProfileException(
            'Akun admin belum terdaftar dengan role yang benar di database.',
          );
        }
        rethrow;
      } catch (_) {
        await _service.logout();
        rethrow;
      }

      if (profile == null || profile.role != expectedRole) {
        _roleRejectedSession = true;
        await _service.logout();
        throw const LoginRoleMismatchException();
      }

      user = profile;
      loading = false;
      notifyListeners();
    } finally {
      _checkingLogin = false;
    }
  }

  Future<void> register(
    String name,
    String kelas,
    String email,
    String password,
  ) async {
    _registering = true;
    try {
      await _service.register(name, kelas, email, password);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      user = await _service.fetchProfile(uid);
      loading = false;
      notifyListeners();
    } finally {
      _registering = false;
    }
  }

  Future<void> logout() => _service.logout();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class LoginRoleMismatchException implements Exception {
  const LoginRoleMismatchException();
}

class LoginProfileException implements Exception {
  final String message;
  const LoginProfileException(this.message);
}
