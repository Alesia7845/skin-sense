import 'package:skinsense/features/recommendation/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
}
