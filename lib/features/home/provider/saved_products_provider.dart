import 'package:flutter_riverpod/flutter_riverpod.dart';

final savedProductsProvider =
    NotifierProvider<SavedProductsController, Set<String>>(
  SavedProductsController.new,
);

class SavedProductsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String productId) {
    final savedProducts = {...state};

    if (!savedProducts.add(productId)) {
      savedProducts.remove(productId);
    }

    state = savedProducts;
  }
}