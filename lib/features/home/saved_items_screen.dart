import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model/productModel.dart';
import 'provider/product_provider.dart';
import 'provider/saved_products_provider.dart';

class SavedItemsScreen extends ConsumerWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final savedProductIds = ref.watch(savedProductsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Saved Items',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: productsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load saved items')),
        data: (products) {
          final savedProducts = products
              .where((product) => savedProductIds.contains(product.id))
              .toList();

          if (savedProducts.isEmpty) {
            return const _EmptySavedItems();
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: savedProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 18,
              childAspectRatio: .68,
            ),
            itemBuilder: (context, index) => _SavedProductCard(
              product: savedProducts[index],
            ),
          );
        },
      ),
    );
  }
}

class _EmptySavedItems extends StatelessWidget {
  const _EmptySavedItems();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 58,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 18),
            const Text(
              'No Saved Items!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any saved items.\nGo to home and add some.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedProductCard extends ConsumerWidget {
  final Product product;

  const _SavedProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xfff1f1f1),
                      child: Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  child: IconButton(
                    tooltip: 'Remove from saved items',
                    onPressed: () => ref
                        .read(savedProductsProvider.notifier)
                        .toggle(product.id),
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          '\$${product.price.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}