import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbital',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MapScreen(),
    );
  }
}


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {  
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(1.2949135522168174, 103.77368916884653),
    zoom: 11.5,
  );

  @override
  Widget build(BuildContext context) {
    _promtLocationPerms();
    return const Scaffold(
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
      ),
    );
  }
  
  Future<void> _promtLocationPerms() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('location services are disabled');
    }
    LocationPermission perms = await Geolocator.checkPermission();
    if (perms == LocationPermission.denied) {
      perms = await Geolocator.requestPermission();
      if (perms == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (perms == LocationPermission.deniedForever) {
      return Future.error('location permission are permently denied, we cannot request it.');
    }
  }

}



