import 'package:cartiva/features/home/model/productModel.dart';
import 'package:cartiva/features/home/provider/product_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();

    final searches = prefs.getStringList('recent_searches') ?? [];

    if (!mounted) return;

    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _saveRecentSearch(String search) async {
    final trimmedSearch = search.trim();

    if (trimmedSearch.isEmpty) return;

    final updatedSearches = List<String>.from(_recentSearches);

    updatedSearches.remove(trimmedSearch);
    updatedSearches.insert(0, trimmedSearch);

    if (updatedSearches.length > 10) {
      updatedSearches.removeLast();
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'recent_searches',
      updatedSearches,
    );

    if (!mounted) return;

    setState(() {
      _recentSearches = updatedSearches;
    });
  }

  Future<void> _removeRecentSearch(String search) async {
    final updatedSearches = List<String>.from(_recentSearches);

    updatedSearches.remove(search);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'recent_searches',
      updatedSearches,
    );

    if (!mounted) return;

    setState(() {
      _recentSearches = updatedSearches;
    });
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('recent_searches');

    if (!mounted) return;

    setState(() {
      _recentSearches.clear();
    });
  }

  void _selectRecentSearch(String search) {
    _controller.text = search;

    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();

    setState(() {});
  }

  List<Product> _filterProducts(List<Product> products) {
    final query = _controller.text.trim().toLowerCase();

    if (query.isEmpty) {
      return [];
    }

    return products.where((product) {
      return product.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    final query = _controller.text.trim();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 28,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12,
            ),
            child: SearchBar(
              controller: _controller,
              hintText: 'Search for clothes...',
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: const WidgetStatePropertyAll(
                Colors.white,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: Color(0xFFE6E6E6),
                  ),
                ),
              ),
              leading: const Icon(
                CupertinoIcons.search,
                color: Color(0xFFB3B3B3),
              ),
              trailing: [
                if (query.isNotEmpty)
                  IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(
                      CupertinoIcons.clear_circled_solid,
                    ),
                  ),
              ],
              onChanged: (_) {
                setState(() {});
              },
              onSubmitted: (value) {
                _saveRecentSearch(value);
              },
            ),
          ),

          Expanded(
            child: query.isEmpty
                ? _RecentSearches(
                    searches: _recentSearches,
                    onClearAll: _clearRecentSearches,
                    onRemove: _removeRecentSearch,
                    onTapSearch: _selectRecentSearch,
                  )
                : productsAsync.when(
                    loading: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    error: (error, stackTrace) {
                      return _SearchError(
                        message: error.toString(),
                      );
                    },
                    data: (products) {
                      final results = _filterProducts(products);

                      if (results.isEmpty) {
                        return const _NoResults();
                      }

                      return _ResultsList(
                        products: results,
                        onProductTap: (product) {
                          // Navigate to ProductDetailsScreen here.
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}



class _SearchError extends StatelessWidget {
  final String message;

  const _SearchError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),

            const SizedBox(height: 12),

            const Text(
              'Something went wrong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final VoidCallback onClearAll;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onTapSearch;

  const _RecentSearches({
    required this.searches,
    required this.onClearAll,
    required this.onRemove,
    required this.onTapSearch,
  });

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const Center(
        child: Text('No recent searches', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              TextButton(onPressed: onClearAll, child: const Text('Clear all')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final term = searches[index];

              return ListTile(
                leading: const Icon(CupertinoIcons.time, color: Colors.grey),
                title: Text(term),
                onTap: () => onTapSearch(term),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel, size: 20, color: Colors.grey),
                  onPressed: () => onRemove(term),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}



class _ResultsList extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const _ResultsList({
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return ListTile(
          key: ValueKey(product.id),

          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl,
              width: 56,
              height: 53,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                  ),
                );
              },
            ),
          ),

          title: Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),

          subtitle: Row(
            children: [
              Text(
                '₦${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

              if (product.discount != null) ...[
                const SizedBox(width: 6),

                Text(
                  product.discount!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),

          trailing: const Icon(
            Icons.north_east_rounded,
            size: 18,
          ),

          onTap: () => onProductTap(product),
        );
      },
    );
  }
}



class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Results Found!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try a similar word or something\nmore general.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}