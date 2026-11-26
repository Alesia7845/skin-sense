import 'package:shared_preferences/shared_preferences.dart';
import 'package:skinsense/features/auth/data/auth_repository.dart';
import 'package:skinsense/features/history/data/history_local_datasource.dart';
import 'package:skinsense/features/profile/data/profile_repository.dart';
import 'package:skinsense/features/recommendation/data/product_repository_impl.dart';
import 'package:skinsense/features/recommendation/domain/usecases/generate_recommendation_usecase.dart';
import 'package:skinsense/features/scan/data/datasources/face_validator.dart';
import 'package:skinsense/features/scan/data/datasources/skin_local_classifier.dart';
import 'package:skinsense/features/scan/data/datasources/skin_remote_datasource.dart';
import 'package:skinsense/features/scan/data/repositories/skin_repository_impl.dart';
import 'package:skinsense/features/scan/domain/usecases/scan_usecases.dart';
import 'package:skinsense/features/settings/data/settings_repository.dart';

/// Perakitan dependensi sederhana (tanpa service locator).
class AppDependencies {
  AppDependencies._({
    required this.auth,
    required this.settings,
    required this.profile,
    required this.history,
    required this.validateFace,
    required this.analyzeSkin,
    required this.generateRecommendation,
  });

  final AuthRepository auth;
  final SettingsRepository settings;
  final ProfileRepository profile;
  final HistoryLocalDataSource history;
  final ValidateFaceUseCase validateFace;
  final AnalyzeSkinUseCase analyzeSkin;
  final GenerateRecommendationUseCase generateRecommendation;

  static Future<AppDependencies> create() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = SettingsRepository(prefs);

    final skinRepository = SkinRepositoryImpl(
      faceValidator: FaceValidator(),
      remote: SkinRemoteDataSource(),
      local: SkinLocalClassifier(),
      settings: settings,
    );

    return AppDependencies._(
      auth: AuthRepository(prefs),
      settings: settings,
      profile: ProfileRepository(prefs),
      history: HistoryLocalDataSource(),
      validateFace: ValidateFaceUseCase(skinRepository),
      analyzeSkin: AnalyzeSkinUseCase(skinRepository),
      generateRecommendation:
          GenerateRecommendationUseCase(products: ProductRepositoryImpl()),
    );
  }
}
