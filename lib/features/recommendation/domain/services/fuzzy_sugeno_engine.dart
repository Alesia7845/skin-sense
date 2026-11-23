import 'dart:math' as math;

import 'package:skinsense/features/recommendation/domain/entities/need_profile.dart';
import 'package:skinsense/shared/models/skin_type.dart';

enum SensitivityLevel {
  low('rendah'),
  medium('sedang'),
  high('tinggi');

  const SensitivityLevel(this.label);
  final String label;
}

class _Rule {
  const _Rule(this.type, this.level, this.oil, this.hydration, this.gentleness);

  final SkinType type;
  final SensitivityLevel level;

  /// Konsekuen Sugeno orde-nol (nilai tegas 0-100).
  final double oil;
  final double hydration;
  final double gentleness;
}

/// Inferensi Fuzzy Sugeno orde-nol.
///
/// Masukan  : probabilitas tiap kelas dari CNN (derajat keanggotaan kelas)
///            dan tingkat sensitivitas 1-5 (fuzzifikasi rendah/sedang/tinggi).
/// Keluaran : profil kebutuhan kontrol minyak, hidrasi, dan kelembutan.
/// Kondisi kulit campuran tercermin otomatis ketika probabilitas minyak dan
/// kering sama-sama signifikan.
class FuzzySugenoEngine {
  const FuzzySugenoEngine();

  static const _rules = <_Rule>[
    _Rule(SkinType.oily, SensitivityLevel.low, 90, 40, 40),
    _Rule(SkinType.oily, SensitivityLevel.medium, 88, 45, 60),
    _Rule(SkinType.oily, SensitivityLevel.high, 80, 50, 82),
    _Rule(SkinType.dry, SensitivityLevel.low, 20, 90, 55),
    _Rule(SkinType.dry, SensitivityLevel.medium, 20, 92, 75),
    _Rule(SkinType.dry, SensitivityLevel.high, 15, 95, 95),
    _Rule(SkinType.normal, SensitivityLevel.low, 50, 55, 35),
    _Rule(SkinType.normal, SensitivityLevel.medium, 50, 58, 55),
    _Rule(SkinType.normal, SensitivityLevel.high, 45, 62, 82),
  ];

  /// Keanggotaan sensitivitas (s dalam 1..5).
  static Map<SensitivityLevel, double> fuzzifySensitivity(double s) {
    double low = s <= 1 ? 1 : (s >= 3 ? 0 : (3 - s) / 2);
    double high = s <= 3 ? 0 : (s >= 5 ? 1 : (s - 3) / 2);
    double med = (s <= 1 || s >= 5) ? 0 : (s <= 3 ? (s - 1) / 2 : (5 - s) / 2);
    return {
      SensitivityLevel.low: low,
      SensitivityLevel.medium: med,
      SensitivityLevel.high: high,
    };
  }

  NeedProfile infer({
    required Map<SkinType, double> probabilities,
    required int sensitivity,
  }) {
    final mu = fuzzifySensitivity(sensitivity.clamp(1, 5).toDouble());

    double sumW = 0, sumOil = 0, sumHyd = 0, sumGentle = 0;
    final activations = <RuleActivation>[];

    for (final rule in _rules) {
      final w = math.min(probabilities[rule.type] ?? 0, mu[rule.level] ?? 0);
      if (w <= 0) continue;
      sumW += w;
      sumOil += w * rule.oil;
      sumHyd += w * rule.hydration;
      sumGentle += w * rule.gentleness;
      activations.add(RuleActivation(
        description:
            'Kulit ${rule.type.label.toLowerCase()} dan sensitivitas ${rule.level.label}',
        strength: w,
      ));
    }

    if (sumW == 0) {
      return const NeedProfile(oilControl: 50, hydration: 55, gentleness: 55);
    }

    activations.sort((a, b) => b.strength.compareTo(a.strength));
    return NeedProfile(
      oilControl: sumOil / sumW,
      hydration: sumHyd / sumW,
      gentleness: sumGentle / sumW,
      activations: activations,
    );
  }
}
