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

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.batch,
    this.training,
    this.jenisKelamin,
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

      // Sesuaikan dengan kode di backend kamu
      if (g == 'l' || g == 'laki' || g == 'laki-laki' || g == 'male') {
        return 'Laki-laki';
      }
      if (g == 'p' || g == 'perempuan' || g == 'female') {
        return 'Perempuan';
      }

      // fallback: tampilkan apa adanya
      return raw;
    }

    final rawGender =
        json['jenis_kelamin']?.toString() ?? json['gender']?.toString();

    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      batch: parseBatch(json['batch']),
      training: parseTraining(json['training']),
      jenisKelamin: mapGender(rawGender),
    );
  }
}
