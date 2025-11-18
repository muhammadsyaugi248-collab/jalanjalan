class AttendanceModel {
  final String? checkInTime;
  final String? checkOutTime;
  final double latitude;
  final double longitude;

  AttendanceModel({
    this.checkInTime,
    this.checkOutTime,
    required this.latitude,
    required this.longitude,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    double safeDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return AttendanceModel(
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
      latitude: safeDouble(json['latitude']),
      longitude: safeDouble(json['longitude']),
    );
  }
}
