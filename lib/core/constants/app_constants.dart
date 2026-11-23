class AppConstants {
  AppConstants._();

  static const appName = 'SkinSense';
  static const disclaimer =
      'SkinSense bersifat edukatif dan bukan alat diagnosis medis. '
      'Untuk masalah kulit yang serius, konsultasikan dengan dokter spesialis kulit.';

  /// Endpoint klasifikasi pada backend FastAPI.
  static const classifyPath = '/api/v1/classify';
  static const requestTimeout = Duration(seconds: 20);

  static const prefsOnboardingDone = 'onboarding_done';
  static const prefsServerUrl = 'server_url';
  static const prefsProfile = 'user_profile';
}
