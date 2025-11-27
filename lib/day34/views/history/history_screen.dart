import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

import 'package:jalanjalan/day34/services/api.dart';
import 'package:jalanjalan/day34/services/attendance_service.dart';
import 'package:jalanjalan/models/history_model.dart';

enum HistoryFilter { week, month, year, all }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _authApi = AuthAPI();

  HistoryAbsen? _history;
  bool _isLoading = false;
  String? _error;
  HistoryFilter _selectedFilter = HistoryFilter.week;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AuthAPI.getHistoryAbsen();
      if (!mounted) return;
      setState(() {
        _history = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil history: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// 🔥 FILTER DENGAN RANGE YANG TIDAK TUMPAH-TINDAH
  List<Datum> _getFilteredHistory() {
    final list = _history?.data ?? [];
    if (list.isEmpty) return [];

    if (_selectedFilter == HistoryFilter.all) return list;

    final now = DateTime.now();

    return list.where((item) {
      final date = item.attendanceDate;
      if (date == null) return false;

      final diff = now.difference(date).inDays;

      // kalau tanggal di masa depan, skip
      if (diff < 0) return false;

      switch (_selectedFilter) {
        case HistoryFilter.week:
          // 0–7 hari terakhir
          return diff <= 7;

        case HistoryFilter.month:
          // 8–30 hari terakhir
          return diff > 7 && diff <= 30;

        case HistoryFilter.year:
          // 31–365 hari terakhir
          return diff > 30 && diff <= 365;

        case HistoryFilter.all:
          return true;
      }
    }).toList();
  }

  Future<void> _deleteAbsen(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Absen'),
        content: const Text(
          'Yakin ingin menghapus data absen ini?\n'
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final msg = await AttendanceService.deleteAbsen(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      await _loadHistory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus absen: $e')));
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '-';
    return time;
  }

  // =========================
  //  UI
  // =========================

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredHistory();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F5F7),
        foregroundColor: Colors.black,
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterRow(),
            if (_error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada riwayat absensi.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildHistoryCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      color: const Color(0xFFF5F5F7),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFilterChip('1 Minggu', HistoryFilter.week),
              _buildFilterChip('1 Bulan', HistoryFilter.month),
              _buildFilterChip('1 Tahun', HistoryFilter.year),
              _buildFilterChip('Semua', HistoryFilter.all),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, HistoryFilter filter) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedFilter = filter);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Datum item) {
    final date = _formatDate(item.attendanceDate);
    final checkInTime = _formatTime(item.checkInTime);
    final checkOutTime = _formatTime(item.checkOutTime);
    final checkInAddress = item.checkInAddress ?? '';
    final checkOutAddress = item.checkOutAddress ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanggal + tombol delete
            Row(
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    if (item.id != null) _deleteAbsen(item.id!);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Hapus',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // CHECK IN block
            _buildCheckRow(
              label: 'Check-in',
              time: checkInTime,
              address: checkInAddress,
              icon: Icons.login,
              lat: item.checkInLat,
              lng: item.checkInLng,
            ),
            const SizedBox(height: 8),

            Container(height: 1, color: Colors.grey.shade300),

            const SizedBox(height: 8),

            // CHECK OUT block
            _buildCheckRow(
              label: 'Check-out',
              time: checkOutTime,
              address: checkOutAddress,
              icon: Icons.logout,
              lat: item.checkOutLat,
              lng: item.checkOutLng,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow({
    required String label,
    required String time,
    required String address,
    required IconData icon,
    double? lat,
    double? lng,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              HistoryAddressText(address: address, lat: lat, lng: lng),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget untuk menampilkan alamat:
/// - kalau address sudah berupa teks nama jalan → pakai langsung
/// - kalau address masih koordinat / kosong tapi ada lat/lng → reverse geocoding
class HistoryAddressText extends StatelessWidget {
  final String? address;
  final double? lat;
  final double? lng;

  const HistoryAddressText({super.key, this.address, this.lat, this.lng});

  bool _looksLikeCoordinate(String text) {
    final reg = RegExp(r'^[0-9\-\.,\s]+$');
    return reg.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    // kalau sudah ada address yang “bener” (bukan koordinat), langsung pakai
    if (address != null &&
        address!.isNotEmpty &&
        !_looksLikeCoordinate(address!)) {
      return Text(
        address!,
        style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
      );
    }

    // kalau lat/lng nggak ada, tidak usah tampil apa-apa
    if (lat == null || lng == null) {
      return const SizedBox.shrink();
    }

    // kalau cuma koordinat → reverse geocoding
    return FutureBuilder<List<Placemark>>(
      future: placemarkFromCoordinates(lat!, lng!),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Text(
            '-',
            style: TextStyle(fontSize: 11, color: Colors.blueGrey),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            '-',
            style: TextStyle(fontSize: 11, color: Colors.blueGrey),
          );
        }

        final p = snapshot.data!.first;
        final text = "${p.street ?? ''}, ${p.locality ?? ''}"
            .replaceAll(' ,', '')
            .trim();

        return Text(
          text.isEmpty ? '-' : text,
          style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
        );
      },
    );
  }
}
