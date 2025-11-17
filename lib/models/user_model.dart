class UserModel {
  final String name;
  final String email;
  final String batch;

  UserModel({required this.name, required this.email, required this.batch});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      batch: json['batch'] ?? '',
    );
  }
}
