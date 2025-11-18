class HistoryModel {
  final int id;
  final String date;
  final String checkIn;
  final String checkOut;
  final double latitude;
  final double longitude;

  HistoryModel({
    required this.id,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.latitude,
    required this.longitude,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    double safeDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return HistoryModel(
      id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      date: json['date']?.toString() ?? json['created_at']?.toString() ?? '',
      checkIn: json['check_in_time']?.toString() ?? '',
      checkOut: json['check_out_time']?.toString() ?? '',
      latitude: safeDouble(json['latitude']),
      longitude: safeDouble(json['longitude']),
    );
  }
}
