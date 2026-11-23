import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';

enum FaceCheck { valid, noFace, multipleFaces, unavailable }

abstract class SkinRepository {
  /// Validasi wajah di perangkat (ML Kit) sebelum foto diunggah.
  Future<FaceCheck> validateFace(String imagePath);

  /// Mengklasifikasikan tipe kulit dari foto.
  Future<SkinAnalysis> analyze(String imagePath);
}
