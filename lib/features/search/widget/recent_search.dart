import 'package:flutter/material.dart';

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
                leading: const Icon(Icons.access_time, color: Colors.grey),
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
