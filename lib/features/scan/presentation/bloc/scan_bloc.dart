import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinsense/core/errors/failures.dart';
import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';
import 'package:skinsense/features/scan/domain/repositories/skin_repository.dart';
import 'package:skinsense/features/scan/domain/usecases/scan_usecases.dart';

// ---- Events ----
abstract class ScanEvent extends Equatable {
  const ScanEvent();
  @override
  List<Object?> get props => [];
}

/// Dipicu saat foto langsung diambil dari kamera in-app (CameraPreview).
class ScanCapturedPathRequested extends ScanEvent {
  const ScanCapturedPathRequested(this.imagePath);
  final String imagePath;
  @override
  List<Object?> get props => [imagePath];
}

/// Dipicu saat user memilih foto dari galeri.
class ScanGalleryRequested extends ScanEvent {
  const ScanGalleryRequested();
}

class ScanReset extends ScanEvent {
  const ScanReset();
}

// ---- State ----
enum ScanStatus { initial, validating, analyzing, success, failure }

class ScanState extends Equatable {
  const ScanState({
    this.status = ScanStatus.initial,
    this.imagePath,
    this.analysis,
    this.message,
  });

  final ScanStatus status;
  final String? imagePath;
  final SkinAnalysis? analysis;
  final String? message;

  bool get isBusy =>
      status == ScanStatus.validating || status == ScanStatus.analyzing;

  @override
  List<Object?> get props => [status, imagePath, analysis, message];
}

// ---- Bloc ----
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanBloc({
    required ValidateFaceUseCase validateFace,
    required AnalyzeSkinUseCase analyzeSkin,
    ImagePicker? picker,
  })  : _validateFace = validateFace,
        _analyzeSkin = analyzeSkin,
        _picker = picker ?? ImagePicker(),
        super(const ScanState()) {
    on<ScanCapturedPathRequested>(_onCapturedPath);
    on<ScanGalleryRequested>(_onGalleryRequested);
    on<ScanReset>((event, emit) => emit(const ScanState()));
  }

  final ValidateFaceUseCase _validateFace;
  final AnalyzeSkinUseCase _analyzeSkin;
  final ImagePicker _picker;

  Future<void> _onCapturedPath(
    ScanCapturedPathRequested event,
    Emitter<ScanState> emit,
  ) async {
    await _processImage(event.imagePath, emit);
  }

  Future<void> _onGalleryRequested(
    ScanGalleryRequested event,
    Emitter<ScanState> emit,
  ) async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        imageQuality: 88,
      );
      if (file == null) return;
      await _processImage(file.path, emit);
    } catch (e) {
      emit(ScanState(status: ScanStatus.failure, message: 'Gagal membuka galeri: $e'));
    }
  }

  Future<void> _processImage(
    String path,
    Emitter<ScanState> emit,
  ) async {
    try {
      emit(ScanState(status: ScanStatus.validating, imagePath: path));
      final check = await _validateFace(path);

      if (check == FaceCheck.noFace) {
        emit(const ScanState(
          status: ScanStatus.failure,
          message:
              'Wajah tidak terdeteksi. Pastikan wajah terlihat jelas dan pencahayaan cukup.',
        ));
        return;
      }
      if (check == FaceCheck.multipleFaces) {
        emit(const ScanState(
          status: ScanStatus.failure,
          message:
              'Terdeteksi lebih dari satu wajah. Gunakan foto satu wajah saja.',
        ));
        return;
      }

      emit(ScanState(status: ScanStatus.analyzing, imagePath: path));
      final analysis = await _analyzeSkin(path);
      emit(ScanState(
        status: ScanStatus.success,
        imagePath: path,
        analysis: analysis,
      ));
    } on Failure catch (f) {
      emit(ScanState(status: ScanStatus.failure, message: f.message));
    } catch (e) {
      emit(ScanState(
          status: ScanStatus.failure, message: 'Terjadi kesalahan: $e'));
    }
  }
}
