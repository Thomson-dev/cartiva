import 'package:flutter/material.dart';
import '../model/productModel.dart';
import 'productCard.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'No products found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          key: ValueKey(product.name),
          product: product,
        );
      },
    );
  }
}