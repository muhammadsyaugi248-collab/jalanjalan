import 'package:http/http.dart' as http;
import 'package:jalanjalan/models/user_model.dart';
import 'dart:convert';
import '../constant/endpoint.dart';
import '../preferens/preference_handler.dart';

class AttendanceService {
  // Ambil data user
  static Future<UserModel?> getProfile() async {
    final token = await PreferenceHandler.getToken();
    final response = await http.get(
      Uri.parse(Endpoint.profile),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      return UserModel.fromJson(jsonRes['data']);
    }
    return null;
  }

  // Absen masuk
  static Future<String> checkIn(double lat, double long) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.post(
      Uri.parse(Endpoint.checkIn),
      headers: {"Authorization": "Bearer $token"},
      body: {"latitude": lat.toString(), "longitude": long.toString()},
    );
    final jsonRes = jsonDecode(response.body);
    return jsonRes['message'] ?? 'Absen masuk gagal';
  }

  // Absen pulang
  static Future<String> checkOut(double lat, double long) async {
    final token = await PreferenceHandler.getToken();
    final response = await http.post(
      Uri.parse(Endpoint.checkOut),
      headers: {"Authorization": "Bearer $token"},
      body: {"latitude": lat.toString(), "longitude": long.toString()},
    );
    final jsonRes = jsonDecode(response.body);
    return jsonRes['message'] ?? 'Absen pulang gagal';
  }
}
