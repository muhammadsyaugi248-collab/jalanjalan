import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/models/loginmodel.dart';

class ApiServiceLogin {
  static Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    try {
      final response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {"email": email, "password": password},
      );

      log("LOGIN STATUS: ${response.statusCode}");
      log("LOGIN RESPONSE RAW: ${response.body}");

      // Pastikan response body merupakan JSON valid
      dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (_) {
        throw Exception("Format respons server tidak valid");
      }

      log("LOGIN PARSED RESPONSE: $jsonResponse");

      if (response.statusCode == 200) {
        return LoginModel.fromJson(jsonResponse);
      } else {
        final msg = (jsonResponse is Map && jsonResponse["message"] != null)
            ? jsonResponse["message"].toString()
            : "Login gagal";

        throw Exception(msg);
      }
    } catch (e) {
      // PERBAIKAN PENTING UNTUK FLUTTER WEB
      throw Exception(e.toString());
    }
  }
}
