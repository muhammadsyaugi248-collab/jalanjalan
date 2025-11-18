import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';

class AuthAPI {
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
    // ambil message jika ada
    throw Exception(body['message'] ?? 'Login gagal');
  }
}
