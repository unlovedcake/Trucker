import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:trucker/services/bottom_navigation/bottom_navigation_provider.dart';

// ignore: must_be_immutable
class Navbar extends StatefulWidget {
  void Function(int)? onTabChange;
  Navbar({super.key, required this.onTabChange});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    // return Consumer<BottomNavigationProvider>(
    //   builder: (context, provider, child) {
    //     return Container(
    //       child: GNav(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           gap: 10,
    //           color: Colors.grey[400],
    //           activeColor: const Color(0xFF6D9886),
    //           onTabChange: (value) => provider.setIndex(value),
    //           tabs: const [
    //             //ICONS are placeholder
    //             GButton(
    //               icon: Icons.directions_car_filled,
    //               text: "Track",
    //             ),
    //             GButton(
    //               icon: Icons.insights_outlined,
    //               text: "Insights",
    //             ),
    //           ]),
    //     );
    //   },
    // );
    return Container(
      child: GNav(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          gap: 10,
          color: Colors.grey[400],
          activeColor: const Color(0xFF6D9886),
          onTabChange: (value) => widget.onTabChange!(value),
          tabs: const [
            //ICONS are placeholder
            GButton(
              icon: Icons.directions_car_filled,
              text: "Track",
            ),
            GButton(
              icon: Icons.insights_outlined,
              text: "Insights",
            ),
          ]),
    );
  }
}
