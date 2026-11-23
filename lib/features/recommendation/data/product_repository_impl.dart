import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:skinsense/features/recommendation/domain/entities/product.dart';
import 'package:skinsense/features/recommendation/domain/repositories/product_repository.dart';

/// Katalog produk dibaca dari `assets/data/products.json`.
class ProductRepositoryImpl implements ProductRepository {
  List<Product>? _cache;

  @override
  Future<List<Product>> getAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/products.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return _cache = list.map(Product.fromJson).toList();
  }
}
