import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/day34/services/api.dart';
import 'package:jalanjalan/day34/services/attendance_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _googleMapController;
  LatLng _currentPosition = LatLng(-6.2000, 108.816666);
  String _currentAddress = "Alamat tidak ditemukan";
  Marker? _marker;
  bool isLoading = false;
  bool isLoadingOut = false;
  String name = '';
  String token = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = LatLng(position.latitude, position.longitude);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );
    Placemark place = placemarks[0];

    setState(() {
      _marker = Marker(
        markerId: const MarkerId("lokasi_saya"),
        position: _currentPosition,
        infoWindow: InfoWindow(
          title: "Lokasi Anda",
          snippet: "${place.street}, ${place.locality}",
        ),
      );

      _currentAddress =
          "${place.name}, ${place.street}, ${place.locality}, ${place.country}, ${place.postalCode}";

      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );
    });
  }

  Future<void> _loadInfo() async {
    final t = await PreferenceHandler.getToken();
    setState(() => token = t ?? '');
    // optionally fetch profile using /profile endpoint (AttendanceService can be added)
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        throw Exception('Permission denied');
    }
    if (permission == LocationPermission.deniedForever)
      throw Exception('Permission denied forever');
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _onCheckIn() async {
    try {
      final p = await _determinePosition();
      final msg = await AttendanceService.checkIn(p.latitude, p.longitude);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _onCheckOut() async {
    try {
      final p = await _determinePosition();
      final msg = await AttendanceService.checkOut(p.latitude, p.longitude);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _logout() async {
    await PreferenceHandler.removeLogin();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Absensi'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GoogleMap(
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                ),
              ),
            ),
            Text('Token: ${token.isEmpty ? "Not found" : token}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() => isLoading = true);

                try {
                  Position pos = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );

                  double lat = pos.latitude;
                  double lng = pos.longitude;

                  String attendanceDate = DateFormat(
                    "yyyy-MM-dd",
                  ).format(DateTime.now());
                  String timeNow = DateFormat("HH:mm").format(DateTime.now());

                  final response = await AuthAPI.checkIn(
                    attendanceDate: attendanceDate,
                    CheckInTime: timeNow,
                    checkInLat: lat,
                    checkInLng: lng,
                    checkInAddress: _currentAddress,
                    status: "masuk",
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message ?? "Check-in berhasil"),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Gagal Check-in: $e")));
                }

                setState(() => isLoading = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade400,
                shadowColor: Colors.greenAccent.withOpacity(0.3),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
              ),
              child: Text(
                isLoading ? "Loading..." : "Check In",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                setState(() => isLoadingOut = true);

                try {
                  Position pos = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );

                  double lat = pos.latitude;
                  double lng = pos.longitude;

                  String attendanceDate = DateFormat(
                    "yyyy-MM-dd",
                  ).format(DateTime.now());
                  String timeNow = DateFormat("HH:mm").format(DateTime.now());

                  final response = await AuthAPI.checkOut(
                    attendanceDate: attendanceDate,
                    CheckInTime: timeNow,
                    checkInLat: lat,
                    checkInLng: lng,
                    checkInAddress: _currentAddress,
                    status: "masuk",
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message ?? "Check-Out berhasil"),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal Check-Out: $e")),
                  );
                }

                setState(() => isLoadingOut = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade300,
                elevation: 6,
                shadowColor: Colors.blue.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
              ),
              child: Text(
                isLoadingOut ? "Loading..." : "Check Out",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
