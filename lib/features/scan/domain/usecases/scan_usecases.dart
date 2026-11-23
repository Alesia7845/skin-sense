import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';
import 'package:skinsense/features/scan/domain/repositories/skin_repository.dart';

class ValidateFaceUseCase {
  const ValidateFaceUseCase(this._repository);
  final SkinRepository _repository;

  Future<FaceCheck> call(String imagePath) => _repository.validateFace(imagePath);
}

class AnalyzeSkinUseCase {
  const AnalyzeSkinUseCase(this._repository);
  final SkinRepository _repository;

  Future<SkinAnalysis> call(String imagePath) => _repository.analyze(imagePath);
}
