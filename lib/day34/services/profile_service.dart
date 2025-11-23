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

    print("GET PROFILE -> TOKEN: $token");

    final res = await http.get(Uri.parse(Endpoint.profile), headers: headers);

    print("GET PROFILE STATUS: ${res.statusCode}");
    print("GET PROFILE BODY  : ${res.body}");

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

  /// Edit profil user (PUT /profile)
  /// name & email wajib
  /// phoneNumber, address, jenisKelamin opsional
  static Future<String> editProfile({
    required String name,
    required String email,
    String? phoneNumber,
    String? address,
    String? jenisKelamin,
  }) async {
    final token = await PreferenceHandler.getToken();

    final headers = {
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final uri = Uri.parse(Endpoint.profile);

    final body = <String, String>{
      "name": name,
      "email": email,
      if (phoneNumber != null) "phone_number": phoneNumber,
      if (address != null) "address": address,
      if (jenisKelamin != null) "jenis_kelamin": jenisKelamin,
    };

    print("EDIT PROFILE -> TOKEN : $token");
    print("EDIT PROFILE -> URL   : ${uri.toString()}");
    print("EDIT PROFILE -> BODY  : $body");

    final res = await http.put(uri, headers: headers, body: body);

    print("EDIT PROFILE STATUS: ${res.statusCode}");
    print("EDIT PROFILE RESP  : ${res.body}");

    final jsonRes = jsonDecode(res.body);

    if (res.statusCode == 200) {
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
