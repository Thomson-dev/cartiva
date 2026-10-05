import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cartiva/features/home/model/productModel.dart';
import 'package:cartiva/features/home/provider/product_provider.dart';
import 'package:cartiva/features/home/widget/category_filter.dart';
import 'package:cartiva/features/home/widget/home_search.dart';
import 'package:cartiva/features/home/widget/product_grid.dart';
import 'package:cartiva/features/notifications/notifications_screen.dart';
import 'package:cartiva/features/search/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProductCategory? _selectedCategory;

  bool _showFilters = false;

  Future<void> _refreshProducts() async {
    ref.invalidate(productsProvider);
    await ref.read(productsProvider.future);
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _selectCategory(ProductCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_selectedCategory == null) {
      return products;
    }

    return products
        .where(
          (product) => product.category == _selectedCategory,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Discover',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: _openNotifications,
              icon: const Icon(
                Icons.notifications_outlined,
                size: 30,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            HomeSearch(
              onSearchTap: _openSearch,
              onFilterTap: _toggleFilters,
            ),

            const SizedBox(height: 8),

            if (_showFilters) ...[
              CategoryFilter(
                selectedCategory: _selectedCategory,
                onCategorySelected: _selectCategory,
              ),

              const SizedBox(height: 18),
            ],

            Expanded(
              child: productsAsync.when(
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },

                error: (error, stack) {
                  return Center(
                    child: Text(
                      'Failed to load products',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                },

                data: (products) {
                  final filteredProducts =
                      _filterProducts(products);

                  return RefreshIndicator(
                    onRefresh: _refreshProducts,
                    child: ProductGrid(
                      products: filteredProducts,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}