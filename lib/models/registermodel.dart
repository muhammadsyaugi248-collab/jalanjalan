import 'package:jalanjalan/models/loginmodel.dart';

class RegisterModel {
  final String message;
  final LoginData data;

  RegisterModel({required this.message, required this.data});

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      message: json['message']?.toString() ?? '',
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }
}
