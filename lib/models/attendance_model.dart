class AttendanceModel {
  final String checkInTime;
  final String checkOutTime;
  final double latitude;
  final double longitude;

  AttendanceModel({
    required this.checkInTime,
    required this.checkOutTime,
    required this.latitude,
    required this.longitude,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      checkInTime: json['check_in_time'] ?? '',
      checkOutTime: json['check_out_time'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}
