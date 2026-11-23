import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinsense/features/history/domain/entities/history_record.dart';
import 'package:skinsense/features/history/presentation/cubit/history_cubit.dart';
import 'package:skinsense/features/profile/domain/entities/user_profile.dart';
import 'package:skinsense/features/recommendation/domain/entities/recommendation.dart';
import 'package:skinsense/features/recommendation/domain/usecases/generate_recommendation_usecase.dart';
import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';

enum RecommendationStatus { loading, success, failure }

class RecommendationState extends Equatable {
  const RecommendationState({
    this.status = RecommendationStatus.loading,
    this.recommendation,
    this.message,
  });

  final RecommendationStatus status;
  final Recommendation? recommendation;
  final String? message;

  @override
  List<Object?> get props => [status, recommendation, message];
}

class RecommendationCubit extends Cubit<RecommendationState> {
  RecommendationCubit({
    required GenerateRecommendationUseCase useCase,
    required HistoryCubit history,
  })  : _useCase = useCase,
        _history = history,
        super(const RecommendationState());

  final GenerateRecommendationUseCase _useCase;
  final HistoryCubit _history;

  Future<void> generate(
    SkinAnalysis analysis,
    UserProfile profile, {
    bool save = true,
  }) async {
    emit(const RecommendationState());
    try {
      final result = await _useCase(analysis: analysis, profile: profile);
      emit(RecommendationState(
        status: RecommendationStatus.success,
        recommendation: result,
      ));
      if (save) {
        await _history.add(HistoryRecord(analysis: analysis, profile: profile));
      }
    } catch (e) {
      emit(RecommendationState(
        status: RecommendationStatus.failure,
        message: 'Gagal menyusun rekomendasi: $e',
      ));
    }
  }
}
