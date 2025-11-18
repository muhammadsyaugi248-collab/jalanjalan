import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String _isLogin = "isLogin";
  static const String _token = "token";
  static const String _darkMode = "darkMode";

  static Future<void> saveLogin(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_isLogin, v);
  }

  static Future<bool?> getLogin() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_isLogin);
  }

  static Future<void> saveToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_token, token);
  }

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_token);
  }

  static Future<void> removeLogin() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_isLogin);
    await p.remove(_token);
  }

  static Future<void> saveDarkMode(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_darkMode, v);
  }

  static Future<bool?> getDarkMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_darkMode);
  }
}
