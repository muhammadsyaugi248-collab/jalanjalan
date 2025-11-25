// To parse this JSON data, do
//
//     final izin = izinFromJson(jsonString);

import 'dart:convert';

Izin izinFromJson(String str) => Izin.fromJson(json.decode(str));

String izinToJson(Izin data) => json.encode(data.toJson());

class Izin {
  String? message;
  IzinData? data;

  Izin({this.message, this.data});

  factory Izin.fromJson(Map<String, dynamic> json) => Izin(
    message: json["message"],
    data: json["data"] == null ? null : IzinData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class IzinData {
  int? id;
  DateTime? attendanceDate;
  String? checkInTime;
  double? checkInLat;
  double? checkInLng;
  String? checkInLocation;
  String? checkInAddress;
  String? status;
  String? alasanIzin;

  IzinData({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkInLat,
    this.checkInLng,
    this.checkInLocation,
    this.checkInAddress,
    this.status,
    this.alasanIzin,
  });

  factory IzinData.fromJson(Map<String, dynamic> json) => IzinData(
    id: json["id"],
    attendanceDate: json["attendance_date"] == null
        ? null
        : DateTime.parse(json["attendance_date"]),
    checkInTime: json["check_in_time"],
    checkInLat: json["check_in_lat"] is String
        ? double.tryParse(json["check_in_lat"])
        : json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"] is String
        ? double.tryParse(json["check_in_lng"])
        : json["check_in_lng"]?.toDouble(),
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "attendance_date": attendanceDate == null
        ? null
        : "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}",
    "check_in_time": checkInTime,
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "status": status,
    "alasan_izin": alasanIzin,
  };
}
