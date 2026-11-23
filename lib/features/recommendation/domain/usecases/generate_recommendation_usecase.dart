import 'package:skinsense/features/profile/domain/entities/user_profile.dart';
import 'package:skinsense/features/recommendation/domain/entities/product.dart';
import 'package:skinsense/features/recommendation/domain/entities/recommendation.dart';
import 'package:skinsense/features/recommendation/domain/repositories/product_repository.dart';
import 'package:skinsense/features/recommendation/domain/services/fuzzy_sugeno_engine.dart';
import 'package:skinsense/features/recommendation/domain/services/routine_builder.dart';
import 'package:skinsense/features/recommendation/domain/services/saw_ranker.dart';
import 'package:skinsense/features/scan/domain/entities/skin_analysis.dart';

/// Pipeline hybrid: Fuzzy Sugeno -> bobot dinamis -> SAW per kategori.
class GenerateRecommendationUseCase {
  const GenerateRecommendationUseCase({
    required ProductRepository products,
    FuzzySugenoEngine engine = const FuzzySugenoEngine(),
    SawRanker ranker = const SawRanker(),
    RoutineBuilder routine = const RoutineBuilder(),
    this.topPerCategory = 3,
  })  : _products = products,
        _engine = engine,
        _ranker = ranker,
        _routine = routine;

  final ProductRepository _products;
  final FuzzySugenoEngine _engine;
  final SawRanker _ranker;
  final RoutineBuilder _routine;
  final int topPerCategory;

  Future<Recommendation> call({
    required SkinAnalysis analysis,
    required UserProfile profile,
  }) async {
    final catalog = await _products.getAll();
    return build(analysis: analysis, profile: profile, catalog: catalog);
  }

  Recommendation build({
    required SkinAnalysis analysis,
    required UserProfile profile,
    required List<Product> catalog,
  }) {
    final need = _engine.infer(
      probabilities: analysis.probabilities,
      sensitivity: profile.sensitivity,
    );

    final avoidKeywords = [
      for (final label in profile.avoidedIngredients)
        ...UserProfile.keywordsFor(label),
    ];
    final dynamicWeights = SawRanker.dynamicWeights(need);

    final result = <ProductCategory, List<RankedProduct>>{};
    for (final category in ProductCategory.values) {
      final candidates = catalog
          .where((p) =>
              p.category == category &&
              p.price <= profile.maxBudget &&
              !p.containsAny(avoidKeywords))
          .toList();

      final fuzzyRanked = _ranker.rank(candidates, dynamicWeights);
      final fixedRanked = _ranker.rank(candidates, SawRanker.fixedWeights);
      final fixedRankById = {
        for (final r in fixedRanked) r.product.id: r.rank,
      };

      result[category] = fuzzyRanked
          .take(topPerCategory)
          .map((r) => r.withFixedRank(fixedRankById[r.product.id] ?? r.rank))
          .toList();
    }

    return Recommendation(
      need: need,
      morning: _routine.morning(need),
      night: _routine.night(need),
      recommendedIngredients: _routine.recommendedIngredients(need, profile),
      avoidedIngredients: _routine.avoidedIngredients(need, profile),
      products: result,
    );
  }
}
