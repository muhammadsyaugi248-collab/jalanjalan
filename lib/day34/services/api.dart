import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/models/checkin.dart';
import 'package:jalanjalan/models/checkout.dart';
import 'package:jalanjalan/models/history_model.dart';
import 'package:jalanjalan/models/historytoday.dart';
import 'package:jalanjalan/models/statistik.dart';

class AuthAPI {
  // ============================
  // REGISTER
  // ============================
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int trainingId,
    required String batchId,
    String profileBase64 = '',
  }) async {
    final res = await http.post(
      Uri.parse(Endpoint.register),
      headers: {"Accept": "application/json"},
      body: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password,
        "jenis_kelamin": jenisKelamin,
        "training_id": trainingId.toString(),
        "batch_id": batchId,
        if (profileBase64.isNotEmpty) "profile": profileBase64,
      },
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) return body;
    throw Exception(body['message'] ?? 'Gagal register');
  }

  // ============================
  // LOGIN
  // ============================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(Endpoint.login),
      headers: {"Accept": "application/json"},
      body: {"email": email, "password": password},
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return body;
    throw Exception(body['message'] ?? 'Login gagal');
  }

  // ============================
  // CHECK-IN DETAIL (pakai waktu & lokasi)
  // ============================
  static Future<Checkin> checkIn({
    required String attendanceDate,
    required String CheckInTime,
    required double checkInLat,
    required double checkInLng,
    required String checkInAddress,
    required String status,
  }) async {
    final String? token = await PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.attendanceIn);
    final response = await http.post(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {
        "attendance_date": attendanceDate,
        "check_in": CheckInTime,
        "check_in_lat": checkInLat.toString(),
        "check_in_lng": checkInLng.toString(),
        "check_in_address": checkInAddress,
        "status": status,
      },
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return Checkin.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"]);
    }
  }

  // ============================
  // CHECK-OUT DETAIL (pakai waktu & lokasi)
  // ============================
  static Future<CheckOut> checkOut({
    required String attendanceDate,
    required String CheckInTime,
    required double checkInLat,
    required double checkInLng,
    required String checkInAddress,
    required String status,
  }) async {
    final String? token = await PreferenceHandler.getToken();
    final url = Uri.parse(Endpoint.attendanceOut);
    final response = await http.post(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {
        "attendance_date": attendanceDate,
        "check_out": CheckInTime,
        "check_out_lat": checkInLat.toString(),
        "check_out_lng": checkInLng.toString(),
        "check_out_address": checkInAddress,
        "status": status,
      },
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return CheckOut.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"]);
    }
  }

  // ============================
  // STATISTIC
  // ============================
  Future<Statistic> getStatistic() async {
    final String? token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan. User belum login.");
    }

    final url = Uri.parse(Endpoint.statistic);

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print("STATISTIC RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Statistic.fromJson(jsonData);
    } else {
      throw Exception("Gagal mengambil statistik");
    }
  }

  // ============================
  // HISTORY TODAY
  // ============================
  Future<HistoryToday> getHistoryToday() async {
    final String? token = await PreferenceHandler.getToken();
    if (token == null) throw Exception("Token tidak ditemukan.");

    final url = Uri.parse(Endpoint.historyToday);

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print("=== HISTORY TODAY DEBUG ===");
    print("URL: $url");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return HistoryToday.fromJson(jsonData);
    } else {
      // PERBAIKAN:
      // kalau belum ada data hari ini, jangan lempar error,
      // cukup kembalikan objek kosong agar dashboard tetap jalan.
      try {
        final body = jsonDecode(response.body);
        final msg = body['message']?.toString() ?? 'Belum ada data hari ini';
        return HistoryToday(message: msg, data: null);
      } catch (_) {
        return HistoryToday(message: "Belum ada data hari ini", data: null);
      }
    }
  }

  // ============================
  // HISTORY ABSEN
  // ============================
  static Future<HistoryAbsen> getHistoryAbsen() async {
    final String? token = await PreferenceHandler.getToken();
    if (token == null) throw Exception("Token tidak ditemukan.");

    final url = Uri.parse(Endpoint.historyAbsen);

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print("HISTORY ABSEN RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return HistoryAbsen.fromJson(jsonData);
    } else {
      throw Exception("Gagal mengambil history absen");
    }
  }
}
