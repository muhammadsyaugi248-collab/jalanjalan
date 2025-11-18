class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? batch;

  UserModel({this.id, required this.name, required this.email, this.batch});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      batch: json['batch']?.toString(),
    );
  }
}
