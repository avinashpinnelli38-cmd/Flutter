import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/user_profile.dart';
import '../services/database_helper.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class ProfileProvider extends ChangeNotifier {
  static const _profileKey = 'user_profile';
  static const _userIdKey = 'auth_user_id';

  final DatabaseHelper _db = DatabaseHelper.instance;

  UserProfile? _profile;
  int? _userId;
  bool _isLoggedIn = false;
  bool _isGuest = false;

  UserProfile? get profile => _profile;
  int? get userId => _userId;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String get displayName =>
      _profile?.name ?? (_isGuest ? 'Guest Driver' : 'Driver');

  String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt::$password')).toString();
  }

  String _generateSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64Encode(bytes);
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_profile == null || _userId == null) {
      await prefs.remove(_profileKey);
      await prefs.remove(_userIdKey);
    } else {
      await prefs.setString(_profileKey, _profile!.toJson());
      await prefs.setInt(_userIdKey, _userId!);
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    _userId = prefs.getInt(_userIdKey);
    if (raw != null) {
      try {
        _profile = UserProfile.fromJson(raw);
        if (_userId == null) {
          _profile = null;
          _isLoggedIn = false;
          await _saveSession();
        } else {
          _isLoggedIn = true;
          _isGuest = false;
          final user = await _db.getUserById(_userId!);
          if (user == null) {
            _profile = null;
            _isLoggedIn = false;
            _userId = null;
            await _saveSession();
          } else {
            _isGuest = user.isGuest;
          }
        }
      } catch (_) {
        _profile = null;
        _isLoggedIn = false;
        await _saveSession();
      }
    }
    notifyListeners();
  }

  /// Registers a new account in the database. Returns null on success or an error message.
  Future<String?> register({
    required String name,
    required String email,
    String? phone,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return 'Enter your email';
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    final existing = await _db.getUserByEmail(normalizedEmail);
    if (existing != null) {
      return 'An account already exists for this email. Please sign in.';
    }

    final salt = _generateSalt();
    final id = await _db.insertUser(
      AppUser(
        name: name.trim(),
        email: normalizedEmail,
        phone: phone?.trim().isEmpty ?? true ? null : phone!.trim(),
        salt: salt,
        passwordHash: _hashPassword(password, salt),
        isGuest: false,
      ),
    );

    await _db.assignOrphanDataToUser(id);

    _profile = UserProfile(
      name: name.trim(),
      email: normalizedEmail,
      phone: phone?.trim().isEmpty ?? true ? null : phone!.trim(),
    );
    _userId = id;
    _isLoggedIn = true;
    _isGuest = false;
    await _saveSession();
    notifyListeners();
    return null;
  }

  /// Signs in with an existing account. Returns null on success or an error message.
  Future<String?> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    final user = await _db.getUserByEmail(normalizedEmail);
    if (user == null) {
      return 'No account found for this email. Please register first.';
    }
    if (user.isGuest) {
      return 'This is a guest account. Please register with your own email.';
    }

    if (_hashPassword(password, user.salt) != user.passwordHash) {
      return 'Incorrect email or password.';
    }

    await _db.assignOrphanDataToUser(user.id!);

    _profile = UserProfile(
      name: user.name,
      email: user.email,
      phone: user.phone,
    );
    _userId = user.id;
    _isLoggedIn = true;
    _isGuest = false;
    await _saveSession();
    notifyListeners();
    return null;
  }

  Future<void> continueAsGuest() async {
    var guest = await _db.getGuestUser();
    if (guest == null) {
      final id = await _db.insertUser(
        AppUser(
          name: 'Guest Driver',
          email: '__guest__',
          salt: 'guest',
          passwordHash: 'guest',
          isGuest: true,
        ),
      );
      guest = await _db.getUserById(id);
    }
    if (guest == null) return;

    _profile = UserProfile(name: guest.name, email: '', phone: guest.phone);
    _userId = guest.id;
    _isLoggedIn = true;
    _isGuest = true;
    await _saveSession();
    notifyListeners();
  }

  /// Updates the profile in the database. Returns null on success or an error message.
  Future<String?> updateProfile(UserProfile profile) async {
    if (_userId == null) return 'Not signed in';

    final newEmail = profile.email.trim().toLowerCase();
    final current = await _db.getUserById(_userId!);
    if (current == null) return 'Account not found';

    if (newEmail != current.email) {
      final conflict = await _db.getUserByEmail(newEmail);
      if (conflict != null) {
        return 'That email is already in use by another account.';
      }
    }

    await _db.updateUserProfile(
      _userId!,
      name: profile.name.trim(),
      phone: profile.phone?.trim().isEmpty ?? true
          ? null
          : profile.phone!.trim(),
      newEmail: newEmail != current.email ? newEmail : null,
    );

    _profile = profile.copyWith(email: newEmail);
    _isLoggedIn = true;
    _isGuest = false;
    await _saveSession();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _profile = null;
    _userId = null;
    _isLoggedIn = false;
    _isGuest = false;
    await _saveSession();
    notifyListeners();
  }
}
