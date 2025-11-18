import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';

class TrainingAPI {
  static Future<List<Map<String, dynamic>>> getTraining() async {
    final token = await PreferenceHandler.getToken();
    final headers = {"Accept": "application/json"};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final res = await http.get(Uri.parse(Endpoint.training), headers: headers);
    log('GET trainings ${res.statusCode} ${res.body}');
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final data = body['data'] as List? ?? [];
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // fallback try singular
    if (res.statusCode == 404) {
      final res2 = await http.get(
        Uri.parse('${Endpoint.baseUrl}/training'),
        headers: headers,
      );
      if (res2.statusCode == 200) {
        final body = jsonDecode(res2.body);
        final data = body['data'] as List? ?? [];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }

    throw Exception('Gagal mengambil data training: ${res.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getBatch() async {
    final token = await PreferenceHandler.getToken();
    final headers = {"Accept": "application/json"};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final res = await http.get(Uri.parse(Endpoint.batch), headers: headers);
    log('GET batches ${res.statusCode} ${res.body}');
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final data = body['data'] as List? ?? [];
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    throw Exception('Gagal mengambil data batch: ${res.statusCode}');
  }
}
