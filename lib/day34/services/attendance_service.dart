// lib/day34/services/attendance_service.dart
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/models/user_model.dart';

class AttendanceService {
  // ============================
  // GET PROFILE
  // ============================
  static Future<UserModel?> getProfile() async {
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      Uri.parse(Endpoint.profile),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    log("GET PROFILE STATUS: ${response.statusCode}");
    log("GET PROFILE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      if (jsonRes is Map && jsonRes["data"] != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(jsonRes["data"]));
      }
      return null;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized (401). Token mungkin tidak valid.");
    } else {
      throw Exception("Gagal mengambil profile: ${response.statusCode}");
    }
  }

  // ============================
  // GET HISTORY ABSEN (ALL)
  // ============================
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      Uri.parse(Endpoint.historyAbsen),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    log("GET HISTORY STATUS: ${response.statusCode}");
    log("GET HISTORY BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      final list = (jsonRes is Map && jsonRes["data"] is List)
          ? jsonRes["data"] as List
          : <dynamic>[];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized (401). Silakan login ulang.");
    } else if (response.statusCode == 404) {
      throw Exception(
        "Endpoint history tidak ditemukan (404). Periksa Endpoint.historyAbsen.",
      );
    } else {
      // coba ambil message dari body bila ada
      try {
        final jsonRes = jsonDecode(response.body);
        if (jsonRes is Map && jsonRes['message'] != null) {
          throw Exception("Gagal mengambil history: ${jsonRes['message']}");
        }
      } catch (_) {}
      throw Exception("Gagal mengambil history: ${response.statusCode}");
    }
  }

  // ============================
  // GET HISTORY TODAY (dengan query param attendance_date opsional)
  // contoh pemanggilan: getHistoryToday(attendanceDate: "2025-11-19")
  // ============================
  static Future<Map<String, dynamic>> getHistoryToday({
    String? attendanceDate,
  }) async {
    final token = await PreferenceHandler.getToken();

    final uri = Uri.parse(Endpoint.historyToday).replace(
      queryParameters: {
        if (attendanceDate != null) "attendance_date": attendanceDate,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    log("GET HISTORY TODAY STATUS: ${response.statusCode}");
    log("GET HISTORY TODAY BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      if (jsonRes is Map) return Map<String, dynamic>.from(jsonRes);
      return {"data": null};
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized (401). Token invalid.");
    } else if (response.statusCode == 404) {
      throw Exception(
        "Endpoint history today tidak ditemukan (404). Periksa Endpoint.historyToday.",
      );
    } else {
      throw Exception("Gagal mengambil history today: ${response.statusCode}");
    }
  }

  // ============================
  // DELETE ABSEN
  // ============================
  static Future<String> deleteAbsen(int id) async {
    final token = await PreferenceHandler.getToken();
    final uri = Uri.parse("${Endpoint.deleteAbsen}?id=$id");

    final response = await http.delete(
      uri,
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    log("DELETE ABSEN STATUS: ${response.statusCode}");
    log("DELETE ABSEN BODY: ${response.body}");

    try {
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body["message"]?.toString() ?? "Berhasil menghapus absen";
      } else {
        throw Exception(
          body["message"]?.toString() ??
              "Gagal menghapus absen (${response.statusCode})",
        );
      }
    } catch (e) {
      // jika response bukan JSON
      if (response.statusCode == 200) {
        return "Berhasil menghapus absen";
      }
      throw Exception("Gagal menghapus absen: ${response.statusCode}");
    }
  }

  // ============================
  // ABSEN MASUK (latitude/longitude)
  // ============================
  static Future<String> checkIn(double lat, double lng) async {
    final token = await PreferenceHandler.getToken();

    final response = await http.post(
      Uri.parse(Endpoint.attendanceIn),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: {"latitude": lat.toString(), "longitude": lng.toString()},
    );

    log("CHECK IN STATUS: ${response.statusCode}");
    log("CHECK IN BODY: ${response.body}");

    try {
      final jsonRes = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonRes["message"]?.toString() ?? "Absen masuk berhasil";
      } else {
        throw Exception(
          jsonRes["message"]?.toString() ??
              "Gagal absen masuk (${response.statusCode})",
        );
      }
    } catch (e) {
      if (response.statusCode == 200) return "Absen masuk berhasil";
      throw Exception("Gagal absen masuk: ${e.toString()}");
    }
  }

  // ============================
  // ABSEN PULANG
  // ============================
  static Future<String> checkOut(double lat, double lng) async {
    final token = await PreferenceHandler.getToken();

    final response = await http.post(
      Uri.parse(Endpoint.attendanceOut),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: {"latitude": lat.toString(), "longitude": lng.toString()},
    );

    log("CHECK OUT STATUS: ${response.statusCode}");
    log("CHECK OUT BODY: ${response.body}");

    try {
      final jsonRes = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonRes["message"]?.toString() ?? "Absen pulang berhasil";
      } else {
        throw Exception(
          jsonRes["message"]?.toString() ??
              "Gagal absen pulang (${response.statusCode})",
        );
      }
    } catch (e) {
      if (response.statusCode == 200) return "Absen pulang berhasil";
      throw Exception("Gagal absen pulang: ${e.toString()}");
    }
  }

  // ============================
  // GET STATISTIC (dynamic range)
  // contoh: getStatistic(start: "2025-07-31", end: "2025-12-31")
  // ============================
  static Future<Map<String, dynamic>> getStatistic({
    required String start,
    required String end,
  }) async {
    final token = await PreferenceHandler.getToken();

    final uri = Uri.parse(
      Endpoint.statistic,
    ).replace(queryParameters: {"start": start, "end": end});

    final response = await http.get(
      uri,
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    log("GET STATISTIC STATUS: ${response.statusCode}");
    log("GET STATISTIC BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      if (jsonRes is Map) return Map<String, dynamic>.from(jsonRes);
      return {};
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized (401). Token invalid.");
    } else {
      throw Exception("Gagal mengambil statistik: ${response.statusCode}");
    }
  }
}
