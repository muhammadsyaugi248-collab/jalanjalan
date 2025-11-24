// lib/day34/view/home/home.dart
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/day34/services/api.dart'; // pastikan ini meng-export AuthAPI

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _googleMapController;
  LatLng _currentPosition = const LatLng(-6.2088, 106.8456);
  String _currentAddress = "Alamat tidak ditemukan";
  Marker? _marker;

  bool isLoading = false;
  bool isLoadingOut = false;
  String token = '';

  // data ringkasan absen hari ini
  String? _checkedInTime;
  String? _checkedOutTime;
  String? _checkedInAddress;
  String? _checkedOutAddress;

  // format
  final String apiTimeFormat = "HH:mm";
  final String uiTimeFormat = "HH.mm.ss";

  @override
  void initState() {
    super.initState();
    _loadInfo();
    _tryGetLocationSilently();
    _loadTodayHistory();
  }

  Future<void> _loadInfo() async {
    final t = await PreferenceHandler.getToken();
    setState(() => token = t ?? '');
  }

  Future<void> _tryGetLocationSilently() async {
    try {
      final pos = await _determinePosition();
      await _updateLocation(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      // ignore
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission denied forever');
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _updateLocation(LatLng pos) async {
    _currentPosition = pos;
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final Placemark? place = placemarks.isNotEmpty ? placemarks.first : null;

      // buat string aman tanpa akses property secara tidak aman
      final name = place?.name ?? '';
      final street = place?.street ?? '';
      final locality = place?.locality ?? '';
      final country = place?.country ?? '';
      final postal = place?.postalCode ?? '';

      final parts = [
        name,
        street,
        locality,
        country,
        postal,
      ].where((s) => s.isNotEmpty).toList();
      final assembled = parts.join(', ');
      final snippet = [street, locality].where((s) => s.isNotEmpty).join(', ');

      setState(() {
        _marker = Marker(
          markerId: const MarkerId("lokasi_saya"),
          position: _currentPosition,
          infoWindow: InfoWindow(title: "Lokasi Anda", snippet: snippet),
        );
        _currentAddress = assembled.isNotEmpty
            ? assembled
            : "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
      });

      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );
    } catch (e) {
      setState(() {
        _currentAddress =
            "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
      });
    }
  }

  Future<void> _loadTodayHistory() async {
    try {
      final api =
          AuthAPI(); // instance sesuai kode Anda yang punya getHistoryToday()
      final history = await api.getHistoryToday();
      setState(() {
        _checkedInTime = history.data?.checkInTime;
        _checkedOutTime = history.data?.checkOutTime;
        _checkedInAddress = history.data?.checkInAddress;
        _checkedOutAddress = history.data?.checkOutAddress;
      });
    } catch (e) {
      // tidak fatal
    }
  }

  Future<void> _onCheckInPressed() async {
    setState(() => isLoading = true);
    try {
      final pos = await _determinePosition();
      await _updateLocation(LatLng(pos.latitude, pos.longitude));

      final attendanceDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final apiTime = DateFormat(apiTimeFormat).format(DateTime.now());
      final uiTime = DateFormat(uiTimeFormat).format(DateTime.now());

      final response = await AuthAPI.checkIn(
        attendanceDate: attendanceDate,
        CheckInTime: apiTime,
        checkInLat: pos.latitude,
        checkInLng: pos.longitude,
        checkInAddress: _currentAddress,
        status: "masuk",
      );

      setState(() {
        _checkedInTime = uiTime;
        _checkedInAddress = _currentAddress;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? "Check-in berhasil")),
      );
    } catch (e) {
      await _loadTodayHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Check-in: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _onCheckOutPressed() async {
    setState(() => isLoadingOut = true);
    try {
      final pos = await _determinePosition();
      await _updateLocation(LatLng(pos.latitude, pos.longitude));

      final attendanceDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final apiTime = DateFormat(apiTimeFormat).format(DateTime.now());
      final uiTime = DateFormat(uiTimeFormat).format(DateTime.now());

      final response = await AuthAPI.checkOut(
        attendanceDate: attendanceDate,
        CheckInTime: apiTime,
        checkInLat: pos.latitude,
        checkInLng: pos.longitude,
        checkInAddress: _currentAddress,
        status: "pulang",
      );

      setState(() {
        _checkedOutTime = uiTime;
        _checkedOutAddress = _currentAddress;
      });

      await _loadTodayHistory();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? "Check-out berhasil")),
      );
    } catch (e) {
      await _loadTodayHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Check-out: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoadingOut = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    _googleMapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 15),
      ),
    );
  }

  Future<void> _logout() async {
    await PreferenceHandler.removeLogin();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildMapBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 320,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            markers: _marker != null ? {_marker!} : {},
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black26),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2),
                ],
              ),
              child: Text(
                "${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressText() {
    return Column(
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            _currentAddress,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "DKI Jakarta, Indonesia",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text("CHECK IN:", style: TextStyle(letterSpacing: 0.6)),
              ),
              Text(
                _checkedInTime ?? "-",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (_checkedInAddress != null) ...[
            const SizedBox(height: 6),
            Text(
              _checkedInAddress!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text("CHECK OUT:", style: TextStyle(letterSpacing: 0.6)),
              ),
              Text(
                _checkedOutTime ?? "-",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (_checkedOutAddress != null) ...[
            const SizedBox(height: 6),
            Text(
              _checkedOutAddress!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final bool canCheckOut =
        _checkedInTime != null && _checkedOutTime == null && !isLoadingOut;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _onCheckInPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "CHECK IN",
                      style: TextStyle(letterSpacing: 2.5, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: canCheckOut ? _onCheckOutPressed : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: canCheckOut
                    ? Colors.white
                    : Colors.grey.shade100,
                side: BorderSide(color: Colors.grey.shade400),
              ),
              child: isLoadingOut
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text(
                      "CHECK OUT",
                      style: TextStyle(
                        letterSpacing: 2.5,
                        color: canCheckOut
                            ? Colors.black
                            : Colors.grey.shade400,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteText() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 28.0),
      child: Text(
        "Pastikan lokasi Anda aktif untuk melakukan absensi",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 18),
            _buildMapBox(),
            _buildAddressText(),
            _buildSummaryCard(),
            const SizedBox(height: 6),
            _buildActionButtons(),
            _buildNoteText(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
