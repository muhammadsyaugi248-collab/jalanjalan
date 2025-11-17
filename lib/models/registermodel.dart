// register_response.dart

import 'dart:convert';

/// Fungsi pembantu untuk mengurai string JSON
RegisterModel registerResponseFromJson(String str) =>
    RegisterModel.fromJson(json.decode(str));

/// Fungsi pembantu untuk mengonversi objek ke string JSON
String registerResponseToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  final String message;
  final Data data;

  RegisterModel({required this.message, required this.data});

  // Factory method untuk membuat instance dari Map (JSON)
  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  // Method untuk mengonversi instance ke Map (JSON)
  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

// --- Kelas Data ---

class Data {
  final String token;
  final User user;

  Data({required this.token, required this.user});

  // Factory method untuk membuat instance dari Map (JSON)
  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(token: json["token"], user: User.fromJson(json["user"]));

  // Method untuk mengonversi instance ke Map (JSON)
  Map<String, dynamic> toJson() => {"token": token, "user": user.toJson()};
}

// --- Kelas User ---

class User {
  final String name;
  final String email;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int id;

  User({
    required this.name,
    required this.email,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  // Factory method untuk membuat instance dari Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json["name"],
    email: json["email"],
    // Mengurai string tanggal menjadi objek DateTime
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  // Method untuk mengonversi instance ke Map (JSON)
  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
  };
}
