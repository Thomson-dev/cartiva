import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_repository.dart';
import '../model/productModel.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final productsProvider =
    AsyncNotifierProvider<ProductController, List<Product>>(
  ProductController.new,
);

class ProductController extends AsyncNotifier<List<Product>> {
  late final ProductRepository _repository;

  @override
  Future<List<Product>> build() async {
    _repository = ref.read(productRepositoryProvider);
    return _repository.getProducts();
  }

  Future<void> refreshProducts() async {
    state = const AsyncLoading();

    try {
      state = AsyncData(await _repository.getProducts());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}