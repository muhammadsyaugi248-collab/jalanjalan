import 'package:flutter/material.dart';
import 'package:jalanjalan/day34/services/profile_service.dart';
import 'package:jalanjalan/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // email tetap pakai email lama (karena tidak diedit)
      final msg = await ProfileService.editProfile(
        name: name,
        email: widget.user.email,
        // tidak kirim phone, address, jenis_kelamin
      );

      // ambil ulang profil dari backend
      final refreshedUser = await ProfileService.getProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // kalau backend belum mengembalikan data baru, pakai user lama + nama baru
      final resultUser = refreshedUser ?? widget.user.copyWith(name: name);

      Navigator.pop(context, resultUser);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan perubahan: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ACCOUNT INFORMATION',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            // HANYA USERNAME
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Username',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
