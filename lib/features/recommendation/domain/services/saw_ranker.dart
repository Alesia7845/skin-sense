import 'package:skinsense/features/recommendation/domain/entities/need_profile.dart';
import 'package:skinsense/features/recommendation/domain/entities/product.dart';
import 'package:skinsense/features/recommendation/domain/entities/recommendation.dart';

/// Simple Additive Weighting.
///
/// Kriteria (urutan bobot): kontrol minyak, hidrasi, kelembutan, rating
/// (semuanya benefit) dan harga (cost).
class SawRanker {
  const SawRanker();

  static const List<double> fixedWeights = [0.2, 0.2, 0.2, 0.2, 0.2];

  /// Bobot dinamis dari profil kebutuhan hasil fuzzy (dinormalisasi jadi 1).
  static List<double> dynamicWeights(NeedProfile need) {
    final raw = [need.oilControl, need.hydration, need.gentleness, 40.0, 30.0];
    final total = raw.fold<double>(0, (a, b) => a + b);
    return raw.map((v) => v / total).toList();
  }

  List<RankedProduct> rank(List<Product> candidates, List<double> weights) {
    if (candidates.isEmpty) return const [];

    double maxOf(double Function(Product) f) =>
        candidates.fold<double>(0, (m, p) => f(p) > m ? f(p) : m);

    final maxOil = maxOf((p) => p.oilControl);
    final maxHyd = maxOf((p) => p.hydration);
    final maxGentle = maxOf((p) => p.gentleness);
    final maxRating = maxOf((p) => p.rating);
    final minPrice = candidates
        .map((p) => p.price.toDouble())
        .fold<double>(double.infinity, (m, v) => v < m ? v : m);

    double norm(double v, double max) => max <= 0 ? 0 : v / max;

    final scored = candidates.map((p) {
      final score = weights[0] * norm(p.oilControl, maxOil) +
          weights[1] * norm(p.hydration, maxHyd) +
          weights[2] * norm(p.gentleness, maxGentle) +
          weights[3] * norm(p.rating, maxRating) +
          weights[4] * (p.price <= 0 ? 0 : minPrice / p.price);
      return (product: p, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return [
      for (var i = 0; i < scored.length; i++)
        RankedProduct(
            product: scored[i].product, score: scored[i].score, rank: i + 1),
    ];
  }
}
