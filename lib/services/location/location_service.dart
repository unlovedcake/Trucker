// location_provider.dart
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trucker/models/users.dart' as user;

class LocationServiceProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  final Completer<GoogleMapController> _googleMapController = Completer();

  List<double?> distanceKilometers = [];

  LatLng? _userLocation;

  LatLng? get userLocation => _userLocation;

  GoogleMapController? mapController;
  Completer<GoogleMapController> get googleMapController =>
      _googleMapController;

  LocationData? _currentLocation;
  Location _location = Location();
  bool _serviceEnabled = false;
  String role = '';
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  final Set<Marker> _userMarker = {};

  Timer? _timer;
  final userId = FirebaseAuth.instance.currentUser;

  LocationData? get currentLocation => _currentLocation;
  Set<Marker> get userMarker => _userMarker;

  LocationServiceProvider() {
    _initializeLocation();

    _callThisEveryTwentySeconds();
  }

  Future<void> getRoleUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    role = prefs.getString('role') ?? '';
  }

  Future<void> _initializeLocation() async {
    // Check if location services are enabled
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    // Request location permission
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }
    await getRoleUser();
    // Get the initial location
    _currentLocation = await _location.getLocation();

    //_userLocation = LatLng(10.2484165, 123.8517766);

    _userLocation =
        LatLng(_currentLocation!.latitude!, currentLocation!.longitude!);

    // Listen to location updates
    _location.onLocationChanged.listen((newLocation) {
      _currentLocation = newLocation;

      moveToPosition();

      notifyListeners();
    });
  }

  void _callThisEveryTwentySeconds() {
    _timer = Timer.periodic(Duration(seconds: 20), (timer) async {
      if (role == 'driver') {
        await _updateLocationDriverInFireStore();
        _userLocation =
            LatLng(_currentLocation!.latitude!, currentLocation!.longitude!);
      }
    });
  }

  Future<void> _updateLocationDriverInFireStore() async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId!.uid)
          .set({
        'location':
            GeoPoint(_currentLocation!.latitude!, _currentLocation!.longitude!),
      }, SetOptions(merge: true));
      print("Location updated: ${userId!.uid}, ${_currentLocation!.longitude}");
    } catch (e) {
      print("Error updating location: $e");
    }

    notifyListeners();
  }

  void _simulateLocationChange() {
    Future.delayed(Duration(seconds: 2), () {
      LatLng newLocation = LatLng(
        _userLocation!.latitude + 0.0001,
        _userLocation!.longitude + 0.0001,
      );
      _userLocation = newLocation;

      moveToPosition();
    });
  }

  moveToPosition() async {
    mapController = await _googleMapController.future;
    mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _userLocation!, zoom: 15)));
  }

  Set<Marker> setUserMarker() {
    if (_userLocation != null) {
      _userMarker.add(Marker(
        markerId: MarkerId('user_marker'),
        position: LatLng(
          _userLocation!.latitude,
          _userLocation!.longitude,
        ),
        infoWindow: InfoWindow(title: "You're here"),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      ));
    }

    return _userMarker;
  }

  @override
  void dispose() {
    mapController?.dispose();
    _timer?.cancel();

    super.dispose();
  }

  double calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371; // Earth radius in kilometers
    final dLat = _degreeToRadian(end.latitude - start.latitude);
    final dLon = _degreeToRadian(end.longitude - start.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(start.latitude)) *
            cos(_degreeToRadian(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  Stream<List<user.UserProfile>> getNearbyDriversList(
      LatLng userLocation, double maxDistanceKm) {
    try {} catch (e) {
      print('Error: $e');
    }
    return FirebaseFirestore.instance
        .collection('Users')
        .where('role', isEqualTo: 'driver')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => user.UserProfile.fromDocument(doc))
          .where((driver) {
        final latLng =
            LatLng(driver.location.latitude, driver.location.longitude);
        final distance = calculateDistance(userLocation, latLng);

        // if (distance <= maxDistanceKm) {
        //   distanceKilometers.add(distance);
        // }

        return distance <= maxDistanceKm;
      }).toList();
    });
  }

  // double getDistanceBetwenUserAndDriver(
  //     double lat1, double lon1, double lat2, double lon2) {
  //   const R = 6371000; // Radius of the Earth in meters
  //   final latDistance = (lat2 - lat1) * pi / 180;
  //   final lonDistance = (lon2 - lon1) * pi / 180;

  //   final a = sin(latDistance / 2) * sin(latDistance / 2) +
  //       cos(lat1 * pi / 180) *
  //           cos(lat2 * pi / 180) *
  //           sin(lonDistance / 2) *
  //           sin(lonDistance / 2);
  //   final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  //   return R * c; // Distance in meters
  // }

  // double convertToKilometers(int meters) {
  //   return meters / 1000;
  // }

  String displayDistance(double latitude, double longitude) {
    final driverLocation = LatLng(latitude, longitude);
    final dis = calculateDistance(userLocation!, driverLocation);

    print('ADS');

    return dis.round() >= 1
        ? '${dis.toStringAsFixed(1)} km'
        : '${dis.toStringAsFixed(1)} m';
  }
}
