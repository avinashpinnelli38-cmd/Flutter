class AppUser {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String salt;
  final String passwordHash;
  final bool isGuest;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.salt = '',
    this.passwordHash = '',
    this.isGuest = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      salt: (map['salt'] as String?) ?? '',
      passwordHash: (map['password_hash'] as String?) ?? '',
      isGuest: ((map['is_guest'] as int?) ?? 0) == 1,
    );
  }
}
