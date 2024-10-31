import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:trucker/components/navbar.dart';
import 'package:trucker/pages/driver/driver_insights_page.dart';
import 'package:trucker/pages/driver/driver_tracks_page.dart';
import 'package:trucker/pages/home_page.dart';
import 'package:trucker/pages/track_page.dart';
import 'package:trucker/services/bottom_navigation/bottom_navigation_provider.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  final List<Widget> _pages = [
    const DriverTracksPage(),
    const DriverInsightsPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: _pages[provider.currentIndex],
          bottomNavigationBar: Consumer<BottomNavigationProvider>(
            builder: (context, provider, child) {
              return Container(
                child: GNav(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    gap: 10,
                    color: Colors.grey[400],
                    activeColor: const Color(0xFF6D9886),
                    onTabChange: (value) => provider.setIndex(value),
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
            },
          ),
        );
      },
    );
  }
}
