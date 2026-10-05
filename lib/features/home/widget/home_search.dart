import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeSearch extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  const HomeSearch({
    super.key,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBar(
            onTap: onSearchTap,
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: Color(0xFFE6E6E6),
                ),
              ),
            ),
            hintText: 'Search for clothes...',
            leading: const Icon(
              CupertinoIcons.search,
              color: Color(0xFFB3B3B3),
            ),
            trailing: [
              IconButton(
                onPressed: () {},
                icon: const Icon(CupertinoIcons.mic),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        FilledButton(
          onPressed: onFilterTap,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Icon(
            CupertinoIcons.slider_horizontal_3,
          ),
        ),
      ],
    );
  }
}