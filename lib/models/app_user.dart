enum UserRole { admin, user }

class AppUser {
  final String uid;
  final String name;
  final String kelas;
  final String email;
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.name,
    required this.kelas,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    final roleValue = (map['role'] ?? '').toString().trim().toLowerCase();
    return AppUser(
      uid: uid,
      name: (map['name'] ?? '') as String,
      kelas: (map['kelas'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      role: roleValue == 'admin' ? UserRole.admin : UserRole.user,
    );
  }
}
