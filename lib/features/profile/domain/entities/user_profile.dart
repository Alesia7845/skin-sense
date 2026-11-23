import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    this.sensitivity = 3,
    this.maxBudget = 150000,
    this.avoidedIngredients = const [],
  });

  /// Tingkat sensitivitas kulit 1 (tidak sensitif) sampai 5 (sangat sensitif).
  final int sensitivity;

  /// Anggaran maksimum per produk (Rupiah).
  final int maxBudget;

  /// Bahan yang ingin dihindari (alergi/tidak cocok).
  final List<String> avoidedIngredients;

  /// Pilihan cepat bahan yang dihindari beserta kata kunci pencocokan INCI.
  static const Map<String, List<String>> knownAllergens = {
    'Alkohol': ['alcohol denat', 'ethanol'],
    'Pewangi': ['fragrance', 'parfum'],
    'Retinol': ['retinol'],
    'Asam salisilat': ['salicylic'],
    'Niacinamide': ['niacinamide'],
    'Minyak esensial': ['essential oil'],
    'Paraben': ['paraben'],
    'AHA': ['glycolic', 'lactic acid', 'mandelic'],
  };

  static List<String> keywordsFor(String label) =>
      knownAllergens[label] ?? [label.toLowerCase().trim()];

  UserProfile copyWith({
    int? sensitivity,
    int? maxBudget,
    List<String>? avoidedIngredients,
  }) {
    return UserProfile(
      sensitivity: sensitivity ?? this.sensitivity,
      maxBudget: maxBudget ?? this.maxBudget,
      avoidedIngredients: avoidedIngredients ?? this.avoidedIngredients,
    );
  }

  Map<String, dynamic> toJson() => {
        'sensitivity': sensitivity,
        'max_budget': maxBudget,
        'avoided': avoidedIngredients,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        sensitivity: (json['sensitivity'] as num?)?.toInt() ?? 3,
        maxBudget: (json['max_budget'] as num?)?.toInt() ?? 150000,
        avoidedIngredients:
            (json['avoided'] as List?)?.map((e) => e.toString()).toList() ??
                const [],
      );

  @override
  List<Object?> get props => [sensitivity, maxBudget, avoidedIngredients];
}
