import 'dart:convert';

class UserProfile {
  final String name;
  final String email;
  final String? phone;

  const UserProfile({required this.name, required this.email, this.phone});

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? 'Driver',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);

  UserProfile copyWith({String? name, String? email, String? phone}) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
