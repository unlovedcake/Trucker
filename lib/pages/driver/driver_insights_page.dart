import 'package:flutter/material.dart';

class DriverInsightsPage extends StatefulWidget {
  const DriverInsightsPage({super.key});

  @override
  State<DriverInsightsPage> createState() => _DriverInsightsPageState();
}

class _DriverInsightsPageState extends State<DriverInsightsPage> {
  @override
  Widget build(BuildContext context) {
    print('Driver Insights Page');
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: const Center(child: Text('Driver Home Page')));
  }
}
