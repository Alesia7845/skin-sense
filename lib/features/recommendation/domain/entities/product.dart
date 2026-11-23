import 'package:equatable/equatable.dart';

enum ProductCategory {
  cleanser,
  serum,
  moisturizer,
  sunscreen;

  String get label => switch (this) {
        ProductCategory.cleanser => 'Cleanser',
        ProductCategory.serum => 'Serum',
        ProductCategory.moisturizer => 'Moisturizer',
        ProductCategory.sunscreen => 'Sunscreen',
      };

  static ProductCategory fromName(String raw) =>
      ProductCategory.values.firstWhere((c) => c.name == raw.toLowerCase());
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.rating,
    required this.oilControl,
    required this.hydration,
    required this.gentleness,
    required this.ingredients,
  });

  final String id;
  final String name;
  final String brand;
  final ProductCategory category;
  final int price;

  /// Rating 0-5.
  final double rating;

  /// Skor manfaat 0-10.
  final double oilControl;
  final double hydration;
  final double gentleness;

  final List<String> ingredients;

  bool containsAny(Iterable<String> keywords) {
    final lower = ingredients.map((e) => e.toLowerCase()).toList();
    return keywords.any((k) => lower.any((i) => i.contains(k.toLowerCase())));
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        brand: json['brand'] as String,
        category: ProductCategory.fromName(json['category'] as String),
        price: (json['price'] as num).toInt(),
        rating: (json['rating'] as num).toDouble(),
        oilControl: (json['oil_control'] as num).toDouble(),
        hydration: (json['hydration'] as num).toDouble(),
        gentleness: (json['gentleness'] as num).toDouble(),
        ingredients:
            (json['ingredients'] as List).map((e) => e.toString()).toList(),
      );

  @override
  List<Object?> get props => [id];
}
