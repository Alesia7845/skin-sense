import 'package:equatable/equatable.dart';
import 'package:skinsense/features/recommendation/domain/entities/need_profile.dart';
import 'package:skinsense/features/recommendation/domain/entities/product.dart';

class RoutineStep extends Equatable {
  const RoutineStep(this.title, this.detail);

  final String title;
  final String detail;

  @override
  List<Object?> get props => [title, detail];
}

class RankedProduct extends Equatable {
  const RankedProduct({
    required this.product,
    required this.score,
    required this.rank,
    this.fixedRank,
  });

  final Product product;

  /// Nilai preferensi SAW (0-1).
  final double score;

  /// Peringkat pada Fuzzy-SAW (bobot dinamis).
  final int rank;

  /// Peringkat pada SAW berbobot tetap (pembanding).
  final int? fixedRank;

  RankedProduct withFixedRank(int value) => RankedProduct(
      product: product, score: score, rank: rank, fixedRank: value);

  @override
  List<Object?> get props => [product, score, rank, fixedRank];
}

class Recommendation extends Equatable {
  const Recommendation({
    required this.need,
    required this.morning,
    required this.night,
    required this.recommendedIngredients,
    required this.avoidedIngredients,
    required this.products,
  });

  final NeedProfile need;
  final List<RoutineStep> morning;
  final List<RoutineStep> night;
  final List<String> recommendedIngredients;
  final List<String> avoidedIngredients;
  final Map<ProductCategory, List<RankedProduct>> products;

  @override
  List<Object?> get props =>
      [need, morning, night, recommendedIngredients, avoidedIngredients, products];
}
