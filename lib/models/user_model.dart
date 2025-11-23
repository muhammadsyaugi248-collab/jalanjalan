class UserModel {
  final int? id;
  final String name;
  final String email;

  /// Contoh tampilan: "Batch 4"
  final String? batch;

  /// Contoh tampilan: "Mobile Programming"
  final String? training;

  /// Contoh tampilan: "Laki-laki" / "Perempuan"
  final String? jenisKelamin;

  /// Contoh tampilan: "+62 8xx ..."
  final String? phoneNumber;

  /// Contoh tampilan: "Jl. Sudirman No. 123, Jakarta Pusat"
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
    String? parseBatch(dynamic rawBatch) {
      if (rawBatch == null) return null;

      // "batch": { "id": 3, "batch_ke": 4, ... }
      if (rawBatch is Map<String, dynamic>) {
        final batchKe = rawBatch['batch_ke']?.toString();
        if (batchKe != null && batchKe.isNotEmpty) {
          return "Batch $batchKe";
        }
      }

      return rawBatch.toString();
    }

    String? parseTraining(dynamic rawTraining) {
      if (rawTraining == null) return null;

      // "training": { "id": 16, "title": "Mobile Programming", ... }
      if (rawTraining is Map<String, dynamic>) {
        final nama =
            rawTraining['title'] ??
            rawTraining['name'] ??
            rawTraining['nama'] ??
            rawTraining['nama_pelatihan'];

        if (nama != null) {
          return nama.toString();
        }
      }

      return rawTraining.toString();
    }

    String? mapGender(String? raw) {
      if (raw == null) return null;
      final g = raw.toLowerCase();

      if (g == 'l' || g == 'laki' || g == 'laki-laki' || g == 'male') {
        return 'Laki-laki';
      }
      if (g == 'p' || g == 'perempuan' || g == 'female') {
        return 'Perempuan';
      }

      return raw;
    }

    final rawGender =
        json['jenis_kelamin']?.toString() ?? json['gender']?.toString();

    // phone & address: coba beberapa nama field yang umum
    final phone =
        json['phone_number']?.toString() ??
        json['phone']?.toString() ??
        json['no_hp']?.toString() ??
        json['telp']?.toString();

    final addr =
        json['address']?.toString() ??
        json['alamat']?.toString() ??
        json['alamat_lengkap']?.toString();

    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      batch: parseBatch(json['batch']),
      training: parseTraining(json['training']),
      jenisKelamin: mapGender(rawGender),
      phoneNumber: phone,
      address: addr,
    );
  }
}
