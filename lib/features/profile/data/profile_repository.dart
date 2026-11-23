import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinsense/core/constants/app_constants.dart';
import 'package:skinsense/features/profile/domain/entities/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._prefs);

  final SharedPreferences _prefs;

  UserProfile load() {
    final raw = _prefs.getString(AppConstants.prefsProfile);
    if (raw == null) return const UserProfile();
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> save(UserProfile profile) async {
    await _prefs.setString(AppConstants.prefsProfile, jsonEncode(profile.toJson()));
  }
}
