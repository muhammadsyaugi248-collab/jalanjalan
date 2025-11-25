import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jalanjalan/day34/services/api.dart';
import 'package:jalanjalan/day34/services/attendance_service.dart';
import 'package:jalanjalan/models/historytoday.dart';
import 'package:jalanjalan/models/statistik.dart';
import 'package:jalanjalan/models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authApi = AuthAPI();

  UserModel? _user;
  Statistic? _statistic;
  HistoryToday? _today;

  bool _isLoading = false;
  String? _error;

  late Timer _timer;
  String _hour = "--";
  String _minute = "--";
  String _second = "--";

  @override
  void initState() {
    super.initState();
    _initClock();
    _loadData();
  }

  void _initClock() {
    void update() {
      final now = DateTime.now();
      if (!mounted) return;
      setState(() {
        _hour = now.hour.toString().padLeft(2, '0');
        _minute = now.minute.toString().padLeft(2, '0');
        _second = now.second.toString().padLeft(2, '0');
      });
    }

    update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      update();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        AttendanceService.getProfile(),
        _authApi.getStatistic(),
        _authApi.getHistoryToday(),
      ]);

      if (!mounted) return;

      _user = results[0] as UserModel?;
      _statistic = results[1] as Statistic?;
      _today = results[2] as HistoryToday?;
    } catch (e) {
      if (!mounted) return;
      _error = e.toString();
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ============================================================
  //  UI
  // ============================================================

  Widget _buildHeader() {
    final name = _user?.name ?? "-";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Hello, ",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text("👋", style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Welcome back to your dashboard",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Avatar saja, tanpa tombol logout
        Container(
          height: 54,
          width: 54,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurvedDivider() {
    return Container(
      margin: const EdgeInsets.only(top: 22, bottom: 14),
      height: 24,
      alignment: Alignment.center,
      child: CustomPaint(
        size: const Size(double.infinity, 24),
        painter: _CurvePainter(),
      ),
    );
  }

  Widget _buildTimeBox(String v) {
    return Container(
      width: 64,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        v,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildCurrentTimeCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.watch_later_outlined, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                "CURRENT TIME",
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeBox(_hour),
              const SizedBox(width: 10),
              const Text(
                ":",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(width: 10),
              _buildTimeBox(_minute),
              const SizedBox(width: 10),
              const Text(
                ":",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(width: 10),
              _buildTimeBox(_second),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    final name = _user?.name ?? "-";
    final email = _user?.email ?? "-";
    final batch = _user?.batch ?? "-";
    final training = _user?.training ?? "-";

    final g = _user?.jenisKelamin?.toUpperCase();
    final gender = g == "L"
        ? "Laki-laki"
        : g == "P"
        ? "Perempuan"
        : g ?? "-";

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ACCOUNT INFORMATION",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          _info("Username", name),
          _divider(),
          _info("Email", email),
          _divider(),
          _info("Batch", batch),
          _divider(),
          _info("Training", training),
          _divider(),
          _info("Jenis Kelamin", gender),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildStatisticsSection() {
    final data = _statistic?.data;

    final totalAbsen = data?.totalAbsen ?? 0;
    final totalMasuk = data?.totalMasuk ?? 0;
    final totalIzin = data?.totalIzin ?? 0;

    int absentDays = totalAbsen - totalMasuk - totalIzin;
    if (absentDays < 0) absentDays = 0;

    final sudahAbsen = data?.sudahAbsenHariIni ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "THIS MONTH STATISTICS",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            _statCard(
              Icons.check,
              "Present",
              sudahAbsen ? "Sudah absen hari ini" : "Belum absen",
            ),
            _statCard(Icons.close, "Absent", "$absentDays Hari"),
          ],
        ),

        Row(
          children: [
            _statCard(Icons.warning, "Late", "$totalIzin Hari"),
            _statCard(Icons.calendar_today, "Total Days", "$totalAbsen Hari"),
          ],
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceToday() {
    final d = _today?.data;
    final inTime = d?.checkInTime ?? "-";
    final outTime = d?.checkOutTime ?? "-";

    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.groups),
              SizedBox(width: 6),
              Text(
                "ATTENDANCE TODAY",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _attItem(Icons.login, "Check-in", inTime),
          const SizedBox(height: 10),
          _attItem(Icons.logout, "Check-out", outTime),
        ],
      ),
    );
  }

  Widget _attItem(IconData icon, String label, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 6),
          Expanded(child: Text(label)),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // NO APPBAR — diganti SafeArea + header custom
      body: SafeArea(
        child: _isLoading && _user == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildCurrentTimeCard(),
                      _buildCurvedDivider(),
                      _buildStatisticsSection(),
                      _buildAttendanceToday(),
                      _buildAccountInfo(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.4);
    path.quadraticBezierTo(w * 0.5, h, w, h * 0.4);

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}
