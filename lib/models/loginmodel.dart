import 'user_model.dart';

class LoginModel {
  final String message;
  final LoginData data;

  LoginModel({required this.message, required this.data});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json['message']?.toString() ?? '',
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }
}

class LoginData {
  final String token;
  final UserModel user;

  LoginData({required this.token, required this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token']?.toString() ?? '',
      user: UserModel.fromJson(Map<String, dynamic>.from(json['user'] ?? {})),
    );
  }
}
