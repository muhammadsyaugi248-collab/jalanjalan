// lib/day34/view/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jalanjalan/day34/services/attendance_service.dart';

/// Halaman Riwayat Absensi
/// Menampilkan daftar absen (check-in / check-out) dengan filter 1 minggu / 1 bulan / 1 tahun
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

enum HistoryFilter { week, month, year, all }

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _allHistory = [];
  HistoryFilter _filter = HistoryFilter.week;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Gunakan AttendanceService.getHistory() sesuai kode Anda.
      final list = await AttendanceService.getHistory();

      // Pastikan semua elemen adalah Map<String, dynamic>
      final parsed = list.map((e) => Map<String, dynamic>.from(e)).toList();

      // Sort descending by date (paling baru di atas)
      parsed.sort((a, b) {
        DateTime da = _parseDate(a['attendance_date']);
        DateTime db = _parseDate(b['attendance_date']);
        return db.compareTo(da);
      });

      if (!mounted) return;
      setState(() {
        _allHistory = parsed;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengambil history: ${e.toString()}")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Parse tanggal dari berbagai kemungkinan format
  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      if (raw is DateTime) return raw;
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      final s = raw.toString();
      return DateTime.parse(s);
    } catch (_) {
      try {
        return DateFormat("yyyy-MM-dd").parse(raw.toString());
      } catch (_) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }
  }

  // Filter list berdasarkan pilihan
  List<Map<String, dynamic>> _getFilteredList() {
    final now = DateTime.now();
    DateTime from;
    switch (_filter) {
      case HistoryFilter.week:
        from = now.subtract(const Duration(days: 7));
        break;
      case HistoryFilter.month:
        final prevMonth = DateTime(now.year, now.month - 1, now.day);
        from = prevMonth;
        break;
      case HistoryFilter.year:
        from = DateTime(now.year - 1, now.month, now.day);
        break;
      case HistoryFilter.all:
        from = DateTime.fromMillisecondsSinceEpoch(0);
        break;
    }

    return _allHistory.where((item) {
      final d = _parseDate(item['attendance_date']);
      return !d.isBefore(from);
    }).toList();
  }

  // Ambil nilai check-in/out dari struktur item (toleran terhadap beberapa nama field)
  String? _getCheckInTime(Map<String, dynamic> item) {
    if (item['check_in_time'] != null) return item['check_in_time'].toString();
    if (item['check_in'] != null && item['check_in'] is String)
      return item['check_in'].toString();
    if (item['checkInTime'] != null) return item['checkInTime'].toString();
    return null;
  }

  String? _getCheckOutTime(Map<String, dynamic> item) {
    if (item['check_out_time'] != null)
      return item['check_out_time'].toString();
    if (item['check_out'] != null && item['check_out'] is String)
      return item['check_out'].toString();
    if (item['checkOutTime'] != null) return item['checkOutTime'].toString();
    return null;
  }

  String? _getCheckInAddress(Map<String, dynamic> item) {
    if (item['check_in_address'] != null)
      return item['check_in_address'].toString();
    if (item['checkInAddress'] != null)
      return item['checkInAddress'].toString();
    if (item['check_in'] is Map && item['check_in']['address'] != null) {
      return item['check_in']['address'].toString();
    }
    return null;
  }

  String? _getCheckOutAddress(Map<String, dynamic> item) {
    if (item['check_out_address'] != null)
      return item['check_out_address'].toString();
    if (item['checkOutAddress'] != null)
      return item['checkOutAddress'].toString();
    if (item['check_out'] is Map && item['check_out']['address'] != null) {
      return item['check_out']['address'].toString();
    }
    return null;
  }

  // Hapus absen dengan konfirmasi
  Future<void> _deleteRecord(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus absen"),
        content: const Text("Yakin ingin menghapus record absen ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final msg = await AttendanceService.deleteAbsen(id);

      if (!mounted) return;
      await _fetchHistory();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: ${e.toString()}")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Format tampilan tanggal: "Rabu, 19 November 2025"
  String _formatDisplayDate(DateTime d) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(d);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(d);
    }
  }

  Widget _buildFilterButtons() {
    Widget b(String label, HistoryFilter f) {
      final selected = _filter == f;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (!mounted) return;
            setState(() {
              _filter = f;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: selected ? Colors.black : Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
      child: Row(
        children: [
          b("1 Minggu", HistoryFilter.week),
          b("1 Bulan", HistoryFilter.month),
          b("1 Tahun", HistoryFilter.year),
          b("Semua", HistoryFilter.all),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final date = _parseDate(item['attendance_date']);
    final dayString = _formatDisplayDate(date);
    final checkIn = _getCheckInTime(item) ?? "-";
    final checkOut = _getCheckOutTime(item) ?? "-";
    final inAddress = _getCheckInAddress(item);
    final outAddress = _getCheckOutAddress(item);

    final id = (item['id'] is int)
        ? item['id'] as int
        : int.tryParse(item['id']?.toString() ?? '') ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        title: Text(
          dayString,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                const Expanded(child: Text("CHECK IN:")),
                Text(checkIn),
              ],
            ),
            if (inAddress != null) ...[
              const SizedBox(height: 6),
              Text(
                inAddress,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text("CHECK OUT:")),
                Text(checkOut),
              ],
            ),
            if (outAddress != null) ...[
              const SizedBox(height: 6),
              Text(
                outAddress,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: id > 0 ? () => _deleteRecord(id) : null,
          tooltip: id > 0 ? 'Hapus' : 'Tidak dapat dihapus',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Absensi"),
        actions: [
          IconButton(onPressed: _fetchHistory, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildFilterButtons(),
          if (_isLoading)
            const LinearProgressIndicator()
          else if (_allHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("Tidak ada riwayat absen."),
            )
          else if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text("Tidak ada riwayat sesuai filter ${_filter.name}."),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchHistory,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24, top: 6),
                  itemCount: filtered.length,
                  itemBuilder: (_, idx) {
                    final item = filtered[idx];
                    return _buildItem(item);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
