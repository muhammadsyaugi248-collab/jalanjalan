import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String isLogin = "isLogin";
  static const String token = "token";

  /// SAVE LOGIN STATUS
  static Future<void> saveLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(isLogin, value);
  }

  /// GET LOGIN STATUS
  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLogin);
  }

  /// REMOVE LOGIN STATUS
  static Future<void> removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isLogin);
    prefs.remove(token);
  }

  /// SAVE TOKEN
  static Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(token, value);
  }

  /// GET TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(token);
  }
}
