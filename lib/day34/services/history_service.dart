import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/models/history_model.dart';

class HistoryService {
  static Future<List<HistoryModel>> getHistory() async {
    final token = await PreferenceHandler.getToken();
    final res = await http.get(
      Uri.parse(Endpoint.history),
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final jsonRes = jsonDecode(res.body);
      final data = jsonRes['data'] as List? ?? [];
      return data
          .map((e) => HistoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      final jsonRes = jsonDecode(res.body);
      throw Exception(jsonRes['message'] ?? 'Gagal mengambil riwayat');
    }
  }
}
