// main_login_model.dart atau login_response.dart

import 'dart:convert';

/// Fungsi pembantu untuk mengurai string JSON
LoginModel loginResponseFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

/// Fungsi pembantu untuk mengonversi objek ke string JSON
String loginResponseToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  final String message;
  final Data data;

  LoginModel({required this.message, required this.data});

  // Factory method untuk membuat instance dari Map (JSON)
  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      LoginModel(message: json["message"], data: Data.fromJson(json["data"]));

  // Method untuk mengonversi instance ke Map (JSON)
  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};

  @override
  String toString() {
    return 'LoginResponse(message: $message, data: $data)';
  }
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

  @override
  String toString() {
    return 'Data(token: $token, user: $user)';
  }
}

// --- Kelas User ---

class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt, // Nullable
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method untuk membuat instance dari Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    // Periksa apakah null sebelum mencoba mengurai tanggal
    emailVerifiedAt: json["email_verified_at"] == null
        ? null
        : DateTime.parse(json["email_verified_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  // Method untuk mengonversi instance ke Map (JSON)
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt?.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, createdAt: $createdAt)';
  }
}
