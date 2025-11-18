class Endpoint {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";

  // Auth
  static const String register = "$baseUrl/register";
  static const String login = "$baseUrl/login";

  // Master Data
  static const String batch = "$baseUrl/batches";
  static const String training = "$baseUrl/trainings";

  // Attendance
  static const String attendanceIn = "$baseUrl/attendance-in";
  static const String attendanceOut = "$baseUrl/attendance-out";

  // Profile & Absence History
  static const String profile = "$baseUrl/profile";
  static const String history = "$baseUrl/history-absen";

  // Edit profile (PUT) — tambahkan ini
  static const String editProfile = "$baseUrl/edit-profile";
  // jika backend edit via /profile, Anda bisa set editProfile = profile di sini
  // static const String editProfile = profile;

  // Delete absen (?id=123)
  static const String deleteAbsen = "$baseUrl/delete-absen";
}
