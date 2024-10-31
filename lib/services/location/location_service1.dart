import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trucker/models/users.dart';
import 'dart:math';

class LocationServiceProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  LatLng? _driverLocation;

  LatLng? get driverLocation => _driverLocation;

  // Update the driver's location and polyline coordinates
  void updateDriverLocation(LatLng newLocation) {
    _driverLocation = newLocation;

    notifyListeners();
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

  Stream<List<UserProfile>> getNearbyDriversList(
      LatLng userLocation, double maxDistanceKm) {
    return FirebaseFirestore.instance
        .collection('Users')
        .where('role', isEqualTo: 'driver')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => UserProfile.fromDocument(doc))
          .where((driver) {
        final latLng =
            LatLng(driver.location.latitude, driver.location.longitude);
        final distance = calculateDistance(userLocation, latLng);
        return distance <= maxDistanceKm;
      }).toList();
    });
  }

  Future<void> updateUserLocation(String userId, GeoPoint geopoint) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'location': geopoint,
      });
    } on FirebaseException catch (e) {
      print('Ann error due to firebase occured $e');
    } catch (err) {
      print('Ann error occured $err');
    }
  }

  // Fetch drivers from Firestore
  Stream<List<UserProfile>> get drivers {
    return _firestore
        .collection('Users')
        .where('role', isEqualTo: 'driver')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromMap(doc.data()))
            .toList());
  }

  Stream<List<UserProfile>> userCollectionStream() {
    return _firestore
        .collection('Users')
        .where('role', isEqualTo: 'driver')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromMap(doc.data()))
            .toList());
  }
}
