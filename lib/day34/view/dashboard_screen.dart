import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/day34/services/api.dart';
import 'package:jalanjalan/day34/services/attendance_service.dart';
import 'package:jalanjalan/day34/view/login/login.dart';
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

  // jam berjalan
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
      if (!mounted) {
        _timer.cancel();
        return;
      }
      update();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profileFuture = AttendanceService.getProfile();
      final statisticFuture = _authApi.getStatistic();
      final todayFuture = _authApi.getHistoryToday();

      final results = await Future.wait([
        profileFuture,
        statisticFuture,
        todayFuture,
      ]);

      if (!mounted) return;

      _user = results[0] as UserModel?;
      _statistic = results[1] as Statistic?;
      _today = results[2] as HistoryToday?;
    } catch (e) {
      if (!mounted) return;
      _error = e.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat dashboard: $e")));
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await PreferenceHandler.removeLogin();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // =========================
  //  UI COMPONENTS
  // =========================

  Widget _buildErrorBanner() {
    if (_error == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final name = _user?.name ?? "-";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
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
        const SizedBox(width: 12),
        Column(
          children: [
            // avatar
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
            const SizedBox(height: 8),
            // tombol logout kecil di bawah avatar
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 20),
              tooltip: "Logout",
            ),
          ],
        ),
      ],
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              _buildTimeBox(_minute),
              const SizedBox(width: 10),
              const Text(
                ":",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              _buildTimeBox(_second),
            ],
          ),
        ],
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

  Widget _buildStatisticsSection() {
    final data = _statistic?.data;
    final totalAbsen = data?.totalAbsen ?? 0;
    final totalMasuk = data?.totalMasuk ?? 0;
    final totalIzin = data?.totalIzin ?? 0;
    int absentDays = totalAbsen - totalMasuk - totalIzin;
    if (absentDays < 0) absentDays = 0;

    final sudahAbsenHariIni = data?.sudahAbsenHariIni ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "THIS MONTH STATISTICS",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            Row(
              children: [
                _buildStatCard(
                  icon: Icons.check_circle_outline,
                  title: "Present",
                  value: sudahAbsenHariIni
                      ? "Sudah absen hari ini"
                      : "Belum absen hari ini",
                ),
                _buildStatCard(
                  icon: Icons.close,
                  title: "Absent",
                  value: "$absentDays Hari",
                ),
              ],
            ),
            Row(
              children: [
                _buildStatCard(
                  icon: Icons.warning_amber_outlined,
                  title: "Late",
                  value: "Total izin: $totalIzin Hari",
                ),
                _buildStatCard(
                  icon: Icons.calendar_today_outlined,
                  title: "Total Days",
                  value: "$totalAbsen Hari",
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceToday() {
    final d = _today?.data;
    final checkInTime = d?.checkInTime ?? "-";
    final checkOutTime = d?.checkOutTime ?? "-";
    final checkInAddress = d?.checkInAddress ?? "-";
    final checkOutAddress = d?.checkOutAddress ?? "-";

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
              Icon(Icons.groups_2_outlined, size: 20),
              SizedBox(width: 6),
              Text(
                "ATTENDANCE TODAY",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildAttendanceItem(
            icon: Icons.login,
            label: "Check-in",
            time: checkInTime,
            address: checkInAddress,
          ),
          const SizedBox(height: 10),
          _buildAttendanceItem(
            icon: Icons.logout,
            label: "Check-out",
            time: checkOutTime,
            address: checkOutAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem({
    required IconData icon,
    required String label,
    required String time,
    required String address,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time.isEmpty ? "-" : time,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            address,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
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

    // mapping jenis kelamin biar rapi
    final rawGender = _user?.jenisKelamin?.toUpperCase();
    final gender = rawGender == 'L'
        ? 'Laki-laki'
        : rawGender == 'P'
        ? 'Perempuan'
        : (rawGender ?? '-');

    return Container(
      margin: const EdgeInsets.only(top: 22, bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ACCOUNT INFORMATION",
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.1),
          ),
          const SizedBox(height: 14),
          _buildInfoRow("Username", name),
          _buildDivider(),
          _buildInfoRow("Email", email),
          _buildDivider(),
          _buildInfoRow("Batch", batch),
          _buildDivider(),
          _buildInfoRow("Training", training),
          _buildDivider(),
          _buildInfoRow("Jenis Kelamin", gender),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 1,
      color: Colors.grey.shade300,
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar DIHAPUS -> pakai SafeArea + header custom
      body: SafeArea(
        child:
            _isLoading && _user == null && _statistic == null && _today == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildErrorBanner(),
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

// Garis melengkung dekoratif
class _CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.4);
    path.quadraticBezierTo(w * 0.5, h, w, h * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
