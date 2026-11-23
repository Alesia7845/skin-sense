import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinsense/core/constants/app_constants.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  bool get onboardingDone =>
      _prefs.getBool(AppConstants.prefsOnboardingDone) ?? false;

  Future<void> setOnboardingDone() async {
    await _prefs.setBool(AppConstants.prefsOnboardingDone, true);
  }

  /// Base URL backend FastAPI. Kosong = mode demo (analisis di perangkat).
  String get serverUrl => _prefs.getString(AppConstants.prefsServerUrl) ?? '';

  Future<void> setServerUrl(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await _prefs.remove(AppConstants.prefsServerUrl);
    } else {
      await _prefs.setString(AppConstants.prefsServerUrl, trimmed);
    }
  }
}
