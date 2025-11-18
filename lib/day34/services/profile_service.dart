// lib/day34/services/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/models/user_model.dart';

class ProfileService {
  /// Ambil profil user (GET /profile)
  static Future<UserModel?> getProfile() async {
    final token = await PreferenceHandler.getToken();
    final headers = {
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final res = await http.get(Uri.parse(Endpoint.profile), headers: headers);

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      final data = jsonRes['data'];
      if (data != null && data is Map<String, dynamic>) {
        return UserModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } else {
      final body = res.body;
      throw Exception('Gagal mengambil profil: ${res.statusCode} -> $body');
    }
  }

  /// Edit profil user (PUT /edit-profile or PUT /profile tergantung backend)
  /// fields: name, email (sesuaikan jika ada field lain)
  static Future<String> editProfile({
    required String name,
    required String email,
  }) async {
    final token = await PreferenceHandler.getToken();
    final headers = {
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    // Gunakan Endpoint.editProfile (pastikan sudah ada di Endpoint)
    final uri = Uri.parse(Endpoint.editProfile);

    final res = await http.put(
      uri,
      headers: headers,
      body: {"name": name, "email": email},
    );

    final jsonRes = jsonDecode(res.body);

    if (res.statusCode == 200) {
      // server mungkin mengembalikan message
      return jsonRes['message']?.toString() ?? 'Profil berhasil diperbarui';
    } else if (res.statusCode == 422 && jsonRes['errors'] != null) {
      // Validasi error dari server (Laravel typical)
      final errors = jsonRes['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstErr = errors[firstKey];
        if (firstErr is List && firstErr.isNotEmpty) {
          throw Exception(firstErr.first.toString());
        } else {
          throw Exception(firstErr.toString());
        }
      }
      throw Exception(jsonRes['message']?.toString() ?? 'Validasi gagal');
    } else {
      throw Exception(
        jsonRes['message']?.toString() ??
            'Gagal mengupdate profil (${res.statusCode})',
      );
    }
  }
}
