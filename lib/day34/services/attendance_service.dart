import 'dart:convert';
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

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      if (jsonRes["data"] != null) {
        return UserModel.fromJson(jsonRes["data"]);
      }
      return null;
    } else {
      throw Exception("Gagal mengambil profile: ${response.statusCode}");
    }
  }

  // ============================
  // GET HISTORY ABSEN
  // ============================
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final token = await PreferenceHandler.getToken();

    final response = await http.get(
      Uri.parse(Endpoint.history),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      final list = jsonRes["data"] as List? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("Gagal mengambil history: ${response.statusCode}");
    }
  }

  // ============================
  // DELETE ABSEN (BONUS)
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

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return body["message"] ?? "Berhasil menghapus absen";
    } else {
      throw Exception(body["message"] ?? "Gagal menghapus absen");
    }
  }

  // ============================
  // ABSEN MASUK
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

    final jsonRes = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return jsonRes["message"] ?? "Absen masuk berhasil";
    } else {
      throw Exception(jsonRes["message"] ?? "Gagal absen masuk");
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

    final jsonRes = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return jsonRes["message"] ?? "Absen pulang berhasil";
    } else {
      throw Exception(jsonRes["message"] ?? "Gagal absen pulang");
    }
  }
}
