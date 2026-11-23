import 'package:equatable/equatable.dart';

/// Aktivasi satu aturan fuzzy, dipakai untuk penjelasan hasil.
class RuleActivation extends Equatable {
  const RuleActivation({required this.description, required this.strength});

  final String description;
  final double strength;

  @override
  List<Object?> get props => [description, strength];
}

/// Profil kebutuhan hasil inferensi Fuzzy Sugeno (skala 0-100).
class NeedProfile extends Equatable {
  const NeedProfile({
    required this.oilControl,
    required this.hydration,
    required this.gentleness,
    this.activations = const [],
  });

  final double oilControl;
  final double hydration;
  final double gentleness;
  final List<RuleActivation> activations;

  static String levelOf(double v) => v < 40 ? 'Rendah' : (v < 70 ? 'Sedang' : 'Tinggi');

  @override
  List<Object?> get props => [oilControl, hydration, gentleness, activations];
}
