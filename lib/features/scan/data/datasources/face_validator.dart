import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:skinsense/features/scan/domain/repositories/skin_repository.dart';

/// Deteksi wajah di perangkat memakai Google ML Kit.
class FaceValidator {
  Future<FaceCheck> validate(String imagePath) async {
    final detector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
    );
    try {
      final faces = await detector.processImage(InputImage.fromFilePath(imagePath));
      if (faces.isEmpty) return FaceCheck.noFace;
      if (faces.length > 1) return FaceCheck.multipleFaces;
      return FaceCheck.valid;
    } catch (_) {
      // ML Kit tidak tersedia (mis. emulator tanpa Google Play Services).
      return FaceCheck.unavailable;
    } finally {
      await detector.close();
    }
  }
}
