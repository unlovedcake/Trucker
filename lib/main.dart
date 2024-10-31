import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trucker/components/navigate.dart';
import 'package:trucker/firebase_options.dart';
import 'package:trucker/pages/driver/driver_dashboard_page.dart';
import 'package:trucker/pages/home_page.dart';
import 'package:trucker/pages/login_page.dart';
import 'package:trucker/pages/track_page.dart';
import 'package:trucker/services/auth/auth_gate.dart';
import 'package:trucker/services/auth/auth_wrapper.dart';
import 'package:trucker/services/auth/login_or_register.dart';
import 'package:trucker/services/bottom_navigation/bottom_navigation_provider.dart';
import 'package:trucker/services/database/database_provider.dart';
import 'package:trucker/services/location/location_service.dart';
import 'package:trucker/themes/theme_provider.dart';

void main() async {
  // firebase setup

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // run app
  runApp(
    MultiProvider(
      providers: [
        // bottom navigation provider
        ChangeNotifierProvider(create: (context) => BottomNavigationProvider()),
        // theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // database provider
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),

        // location provider
        ChangeNotifierProvider(create: (context) => LocationServiceProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/first-page': (context) => const FirstPage(),
        '/home': (context) => const HomePage(),
        '/driver-dashboard': (context) => const DriverDashboardPage(),
      },
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
