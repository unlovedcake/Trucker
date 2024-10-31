import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:trucker/components/my_drawer.dart';
import 'package:trucker/models/users.dart' as user;
import 'package:trucker/models/users.dart';
import 'package:trucker/services/location/location_service.dart';

class Tracks extends StatefulWidget {
  const Tracks({super.key});

  @override
  State<Tracks> createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  double distanceKilometers = 5.0;

  Widget _getMap() {
    final locationProvider = Provider.of<LocationServiceProvider>(context);

    return locationProvider.userLocation == null
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<List<user.UserProfile>>(
            stream: locationProvider.getNearbyDriversList(
                locationProvider.userLocation!, distanceKilometers),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final users = snapshot.data!;

              for (var driver in snapshot.data!) {
                final latitude = driver.location.latitude;
                final longitude = driver.location.longitude;

                users.sort((a, b) {
                  final latLongA =
                      LatLng(a.location.latitude, a.location.longitude);
                  final latLongB =
                      LatLng(b.location.latitude, b.location.longitude);
                  double distanceA = locationProvider.calculateDistance(
                      locationProvider.userLocation!, latLongA);
                  double distanceB = locationProvider.calculateDistance(
                      locationProvider.userLocation!, latLongB);

                  return distanceA.compareTo(distanceB);
                });

                locationProvider.userMarker.add(
                  Marker(
                    markerId: MarkerId(driver.uid),
                    position: LatLng(latitude, longitude),
                    infoWindow: InfoWindow(title: driver.name),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    mapType: MapType.hybrid,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        locationProvider.userLocation!.latitude,
                        locationProvider.userLocation!.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('user_marker'),
                        position: LatLng(
                          locationProvider.userLocation!.latitude,
                          locationProvider.userLocation!.longitude,
                        ),
                        infoWindow: const InfoWindow(title: "You're here"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                      ...locationProvider.userMarker
                    },
                    //markers: locationProvider.userMarker,
                    //polylines: _polylines,
                    onMapCreated: (GoogleMapController controller) {
                      // now we need a variable to get the controller of google map
                      if (!locationProvider.googleMapController.isCompleted) {
                        locationProvider.googleMapController
                            .complete(controller);
                      }
                    },
                  ),
                  MyDraggableSheet(
                      user: users,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Divider(
                              color: Colors.grey[300],
                            ),
                            const Text(
                              'Garbage Trucks',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Column(
                              children: [
                                if (users.isEmpty)
                                  Container(
                                      margin: EdgeInsets.only(top: 20),
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        'No Found Garbage Truck',
                                        style: TextStyle(fontSize: 20),
                                      )),
                                for (int i = 0; i < users.length; i++)
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors
                                              .grey, // Set the border color
                                          width: 1.0, // Set the border width
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            users[i].truckname ?? '',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(users[i].address ?? ''),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            locationProvider.displayDistance(
                                              users[i].location.latitude,
                                              users[i].location.longitude,
                                            ),
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Text(
                                            'away from your home',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getMap(),
      drawer: MyDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'T R U C K E R',
          style: TextStyle(
            color: Color(0xFF6D9886),
          ),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class MyDraggableSheet extends StatefulWidget {
  final Widget child;
  final List<UserProfile> user;
  const MyDraggableSheet({super.key, required this.child, required this.user});

  @override
  State<MyDraggableSheet> createState() => _MyDraggableSheetState();
}

class _MyDraggableSheetState extends State<MyDraggableSheet> {
  final sheet = GlobalKey();
  final controller = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    controller.addListener(onChanged);
  }

  void onChanged() {
    final currentSize = controller.size;
    if (currentSize <= 0.05) collapse();
  }

  void collapse() => animateSheet(getSheet.snapSizes!.first);

  void anchor() => animateSheet(getSheet.snapSizes!.last);

  void expand() => animateSheet(getSheet.maxChildSize);

  void hide() => animateSheet(getSheet.minChildSize);

  void animateSheet(double size) {
    controller.animateTo(
      size,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildCircle(String text) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 40, // Width of the circle
      height: 40, // Height of the circle
      decoration: const BoxDecoration(
        shape: BoxShape.circle, // Makes the container circular
        color: Colors.green, // Background color
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white, // Text color
            fontSize: 20, // Font size
            fontWeight: FontWeight.bold, // Text weight
          ),
        ),
      ),
    );
  }

  void _showUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Estimated Hour Of Collection'),
              const Text(
                '6:30 am - 7:00 am',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircle('M'),
                  _buildCircle('W'),
                  _buildCircle('F'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Previous Route',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.user[0].truckname ?? '',
                  ),
                  const Text(
                    'Current Route',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.user[0].truckname ?? '',
                  ),
                  const Text(
                    'Next Route',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.user[0].truckname ?? '',
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  DraggableScrollableSheet get getSheet =>
      (sheet.currentWidget as DraggableScrollableSheet);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return DraggableScrollableSheet(
        key: sheet,
        initialChildSize: 0.1,
        maxChildSize: 0.95,
        minChildSize: 0,
        expand: true,
        snap: true,
        snapSizes: [
          60 / constraints.maxHeight,
          0.5,
        ],
        controller: controller,
        builder: (BuildContext context, ScrollController scrollController) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                topButtonIndicator(),
                SliverToBoxAdapter(
                  child: Container(
                    height: 25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            expand();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(120, 20),
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                  color: Colors.green, width: 1),
                            ),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showUserDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(120, 20),
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                  color: Colors.green, width: 1),
                            ),
                          ),
                          child: const Icon(
                            Icons.home,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: widget.child,
                ),
              ],
            ),
          );
        },
      );
    });
  }

  SliverToBoxAdapter topButtonIndicator() {
    return SliverToBoxAdapter(
      child: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
            Container(
                child: Center(
                    child: Wrap(children: <Widget>[
              Container(
                  width: 100,
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  )),
            ]))),
          ])),
    );
  }

  SliverToBoxAdapter buttonTruckHome() {
    return SliverToBoxAdapter(
      child: Container(
        height: 25,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(120, 20),
                padding: EdgeInsets.zero,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.green, width: 1),
                ),
              ),
              child: const Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 20,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(120, 20),
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.green, width: 1),
                ),
              ),
              child: const Icon(
                Icons.home,
                color: Colors.black,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
