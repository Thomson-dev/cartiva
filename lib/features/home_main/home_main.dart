import 'package:cartiva/core/app_theme_color.dart';
import 'package:cartiva/features/home/home_screen.dart';
import 'package:cartiva/features/search/search_screen.dart';
import 'package:flutter/material.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({Key? key}) : super(key: key);

  @override
  _HomeMainState createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screen = [
    HomeScreen(),
    SearchScreen(),
    Center(child: Text("Saved screen")),
    Center(child: Text("Cart screen")),
    Center(child: Text("Account screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screen,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _pageController.jumpToPage(_currentIndex);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.secondary,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                activeIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: 'Saved',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag_rounded),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Account',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
