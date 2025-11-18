import 'package:flutter/material.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jalanjalan/day34/services/attendance_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  String token = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
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
            Text('Token: ${token.isEmpty ? "Not found" : token}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onCheckIn,
              child: const Text('Absen Masuk'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onCheckOut,
              child: const Text('Absen Pulang'),
            ),
          ],
        ),
      ),
    );
  }
}
