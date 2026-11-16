
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authChanges =>
      _auth.authStateChanges();

  // Register akun
  Future<void> register({
    required String name,
    required String kelas,
    required String email,
    required String password,
  }) async {
    final result =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _db.collection('users').doc(result.user!.uid).set({
      'user_id': result.user!.uid,
      'name': name.trim(),
      'email': email.trim(),
      'kelas': kelas.trim(),
      'created_at': FieldValue.serverTimestamp(),
      'foto': '',
    });
  }

  // Login akun
  Future<void> login(
    String email,
    String password,
  ) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Logout akun
  Future<void> logout() async {
    await _auth.signOut();
  }
}
