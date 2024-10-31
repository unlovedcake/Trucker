import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trucker/components/my_drawer.dart';
import 'package:trucker/services/location/location_service.dart';

class DriverTracksPage extends StatefulWidget {
  const DriverTracksPage({super.key});

  @override
  State<DriverTracksPage> createState() => _DriverTracksPageState();
}

class _DriverTracksPageState extends State<DriverTracksPage> {
  Widget _getMap() {
    final locationProvider = Provider.of<LocationServiceProvider>(context);

    return locationProvider.userLocation == null
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: locationProvider.userLocation!, zoom: 14),
                mapType: MapType.hybrid,
                markers: {
                  Marker(
                    markerId: MarkerId('driver_marker'),
                    position: LatLng(
                      locationProvider.userLocation!.latitude,
                      locationProvider.userLocation!.longitude,
                    ),
                    infoWindow: InfoWindow(title: "You're here"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  )
                },
                onMapCreated: (GoogleMapController controller) {
                  // now we need a variable to get the controller of google map
                  if (!locationProvider.googleMapController.isCompleted) {
                    locationProvider.googleMapController.complete(controller);
                  }
                },
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    print('Driver Tracks Page');
    return Scaffold(
      body: _getMap(),
      drawer: MyDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'D R I V E R  T R U C K E R ',
          style: TextStyle(
            color: Color(0xFF6D9886),
          ),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
