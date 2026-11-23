import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:skinsense/features/scan/data/datasources/face_validator.dart';
import 'package:skinsense/features/scan/data/datasources/skin_local_classifier.dart';
import 'package:skinsense/features/scan/data/datasources/skin_remote_datasource.dart';
import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';
import 'package:skinsense/features/scan/domain/repositories/skin_repository.dart';
import 'package:skinsense/features/settings/data/settings_repository.dart';
import 'package:skinsense/shared/models/skin_type.dart';

class SkinRepositoryImpl implements SkinRepository {
  SkinRepositoryImpl({
    required FaceValidator faceValidator,
    required SkinRemoteDataSource remote,
    required SkinLocalClassifier local,
    required SettingsRepository settings,
  })  : _faceValidator = faceValidator,
        _remote = remote,
        _local = local,
        _settings = settings;

  final FaceValidator _faceValidator;
  final SkinRemoteDataSource _remote;
  final SkinLocalClassifier _local;
  final SettingsRepository _settings;

  @override
  Future<FaceCheck> validateFace(String imagePath) =>
      _faceValidator.validate(imagePath);

  @override
  Future<SkinAnalysis> analyze(String imagePath) async {
    Map<SkinType, double>? probs;
    var source = AnalysisSource.onDevice;

    final url = _settings.serverUrl;
    if (url.isNotEmpty) {
      try {
        probs = await _remote.classify(baseUrl: url, imagePath: imagePath);
        source = AnalysisSource.server;
      } catch (_) {
        probs = null; // server gagal -> jatuh ke mode demo
      }
    }
    probs ??= await _local.classify(imagePath);

    final normalized = _normalize(probs);
    final best = normalized.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final savedPath = await _persistImage(imagePath);

    return SkinAnalysis(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      imagePath: savedPath,
      skinType: best.key,
      confidence: best.value,
      probabilities: normalized,
      createdAt: DateTime.now(),
      source: source,
    );
  }

  Map<SkinType, double> _normalize(Map<SkinType, double> raw) {
    final total = raw.values.fold<double>(0, (a, b) => a + b);
    return {
      for (final t in SkinType.values)
        t: total <= 0 ? 1 / SkinType.values.length : (raw[t] ?? 0) / total,
    };
  }

  /// Menyalin foto ke penyimpanan aplikasi agar tetap ada di riwayat.
  Future<String> _persistImage(String source) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final scans = Directory(p.join(dir.path, 'scans'));
      if (!await scans.exists()) await scans.create(recursive: true);
      final dest = p.join(
        scans.path,
        '${DateTime.now().microsecondsSinceEpoch}${p.extension(source)}',
      );
      await File(source).copy(dest);
      return dest;
    } catch (_) {
      return source;
    }
  }
}
