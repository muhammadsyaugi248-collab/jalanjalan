// lib/models/user_model.dart

class UserModel {
  final int? id;
  final String name;
  final String email;

  /// batch_ke dari API, misal "4"
  final String? batch;

  /// training_title dari API, misal "Mobile Programming"
  final String? training;

  /// "L" / "P" dari field jenis_kelamin
  final String? jenisKelamin;

  /// Phone & address (kalau backend belum kirim, akan null)
  final String? phoneNumber;
  final String? address;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.batch,
    this.training,
    this.jenisKelamin,
    this.phoneNumber,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? parseBatch(Map<String, dynamic> map) {
      if (map['batch_ke'] != null) {
        return map['batch_ke'].toString();
      }
      if (map['batch'] is Map && map['batch']['batch_ke'] != null) {
        return map['batch']['batch_ke'].toString();
      }
      return null;
    }

    String? parseTraining(Map<String, dynamic> map) {
      if (map['training_title'] != null) {
        return map['training_title'].toString();
      }
      if (map['training'] is Map && map['training']['title'] != null) {
        return map['training']['title'].toString();
      }
      return null;
    }

    return UserModel(
      id: parseId(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      batch: parseBatch(json),
      training: parseTraining(json),
      jenisKelamin: json['jenis_kelamin']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "batch": batch,
      "training": training,
      "jenis_kelamin": jenisKelamin,
      "phone_number": phoneNumber,
      "address": address,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? batch,
    String? training,
    String? jenisKelamin,
    String? phoneNumber,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      batch: batch ?? this.batch,
      training: training ?? this.training,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
    );
  }
}
