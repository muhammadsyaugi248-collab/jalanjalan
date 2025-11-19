class Endpoint {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/ap";

  // Auth
  static const String register = "$baseUrl/register";
  static const String login = "$baseUrl/login";

  // Master Data
  static const String batch = "$baseUrl/batches";
  static const String training = "$baseUrl/trainings";

  // Attendance
  static const String attendanceIn = "$baseUrl/absen/check-in";
  static const String attendanceOut = "$baseUrl/absen/check-out";

  // history (base) - jangan hardcode query di sini
  static const String historyToday = "$baseUrl/absen/today";
  static const String statistic = "$baseUrl/absen/stats";
  static const String historyAbsen = "$baseUrl/absen/history";

  // Profile & Absence
  static const String profile = "$baseUrl/profile";
  static const String editProfile = "$baseUrl/edit-profile";

  // Delete absen (?id=123)
  static const String deleteAbsen = "$baseUrl/absen";
}
