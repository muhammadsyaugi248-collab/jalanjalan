import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDetailScreen extends StatelessWidget {
  final double lat;
  final double lng;
  const MapDetailScreen({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    final initial = CameraPosition(target: LatLng(lat, lng), zoom: 16);
    final marker = Marker(
      markerId: const MarkerId('absen_loc'),
      position: LatLng(lat, lng),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi Absen')),
      body: GoogleMap(initialCameraPosition: initial, markers: {marker}),
    );
  }
}
