import 'package:flutter/material.dart';
import 'package:trucker/components/navbar.dart';
import 'package:trucker/pages/home_page.dart';
import 'package:trucker/pages/track_page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int selectedIndex = 0;

  void navigateBottomBar(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<Widget> _pages = [const Tracks(), const HomePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Navbar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: _pages[selectedIndex],
    );

    //  final bottomNavProvider = Provider.of<BottomNavigationProvider>(context);
    // return Scaffold(
    //   bottomNavigationBar: Navbar(
    //     onTabChange: (index) => bottomNavProvider.currentIndex,
    //   ),
    //   body: _pages[bottomNavProvider.currentIndex],
    // );
  }
}
