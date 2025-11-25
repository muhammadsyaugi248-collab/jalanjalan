import 'package:flutter/material.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/day34/services/attendance_service.dart';
import 'package:jalanjalan/day34/views/login/login.dart';
import 'package:jalanjalan/models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await AttendanceService.getProfile();
      if (!mounted) return;
      setState(() => _user = profile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil profil: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await PreferenceHandler.removeLogin();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  // =========================
  //  BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F5F7),
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading && _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Account Settings'),
                  const SizedBox(height: 8),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () {
                          // TODO: arahkan ke halaman ubah password
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.phone_outlined,
                        title: 'Update Phone Number',
                        onTap: () {
                          // TODO: arahkan ke halaman ubah nomor HP
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.location_on_outlined,
                        title: 'Update Address',
                        onTap: () {
                          // TODO: arahkan ke halaman ubah alamat
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy & Permissions',
                        onTap: () {
                          // TODO: tampilkan pengaturan/privacy
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Application Settings'),
                  const SizedBox(height: 8),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notification Settings',
                        onTap: () {
                          // TODO: buka pengaturan notifikasi
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Theme Mode',
                        onTap: () {
                          // TODO: ubah tema (light/dark)
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        onTap: () {
                          // TODO: pilih bahasa
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('About'),
                  const SizedBox(height: 8),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.info_outline,
                        title: 'App Version',
                        trailing: const Text(
                          'v1.0.0',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {
                          // TODO: hubungkan ke bantuan
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.description_outlined,
                        title: 'Terms & Policies',
                        onTap: () {
                          // TODO: tampilkan ketentuan & kebijakan
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 8),
                  if (_user != null)
                    Center(
                      child: Text(
                        'Logged in as ${_user!.email}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // =========================
  //  SUB WIDGETS
  // =========================

  Widget _buildProfileHeader() {
    final name = _user?.name ?? '-';
    final email = _user?.email ?? '-';
    final initial = name.isNotEmpty
        ? name[0].toUpperCase()
        : (email.isNotEmpty ? email[0].toUpperCase() : '?');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.blueAccent,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade800),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 14),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
