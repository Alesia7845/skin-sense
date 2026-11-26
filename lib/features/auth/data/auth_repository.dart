import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinsense/core/constants/app_constants.dart';
import 'package:skinsense/features/auth/domain/entities/auth_user.dart';

/// Menyimpan sesi login secara persisten di perangkat (cukup login 1x di awal).
class AuthRepository {
  AuthRepository(this._prefs);

  final SharedPreferences _prefs;

  AuthUser? getCurrentUser() {
    final raw = _prefs.getString(AppConstants.prefsAuthUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final cleanEmail = email.trim();
    final derivedName = cleanEmail.contains('@')
        ? cleanEmail.split('@').first.replaceAll('.', ' ')
        : cleanEmail;
    final formattedName = derivedName.isEmpty
        ? 'Pengguna SkinSense'
        : derivedName[0].toUpperCase() + derivedName.substring(1);

    final user = AuthUser(
      id: cleanEmail.toLowerCase(),
      name: formattedName,
      email: cleanEmail,
      loggedInAt: DateTime.now(),
    );
    await _prefs.setString(
      AppConstants.prefsAuthUser,
      jsonEncode(user.toJson()),
    );
    return user;
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final cleanEmail = email.trim();
    final cleanName = name.trim().isEmpty ? 'Pengguna SkinSense' : name.trim();

    final user = AuthUser(
      id: cleanEmail.toLowerCase(),
      name: cleanName,
      email: cleanEmail,
      loggedInAt: DateTime.now(),
    );
    await _prefs.setString(
      AppConstants.prefsAuthUser,
      jsonEncode(user.toJson()),
    );
    return user;
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.prefsAuthUser);
  }
}
