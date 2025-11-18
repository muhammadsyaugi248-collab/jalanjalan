import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/models/registermodel.dart';

class ApiServiceRegister {
  static Future<RegisterModel> register({
    required String name,
    required String email,
    required String password,
    required String batch,
    required String trainingId,
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
          "password_confirmation": password,
          "batch": batch,
          "training_id": trainingId,
        },
      );

      log("REGISTER STATUS: ${response.statusCode}");
      log("REGISTER RESPONSE RAW: ${response.body}");

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
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
