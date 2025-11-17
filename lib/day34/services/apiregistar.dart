// lib/day34/service/api_service_register.dart

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/models/registermodel.dart'; // Pastikan model ini sudah ada

class ApiServiceRegister {
  static Future<RegisterModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.register);

    try {
      final response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation":
              password, // Sesuaikan jika API Anda butuh konfirmasi
        },
      );

      log("REGISTER STATUS: ${response.statusCode}");
      log("REGISTER RESPONSE RAW: ${response.body}");

      dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (_) {
        throw Exception("Format respons server tidak valid");
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Asumsi status 201 (Created) atau 200 (OK) untuk sukses register
        return RegisterModel.fromJson(jsonResponse);
      } else {
        final msg = (jsonResponse is Map && jsonResponse["message"] != null)
            ? jsonResponse["message"].toString()
            : "Registrasi gagal";

        throw Exception(msg);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
