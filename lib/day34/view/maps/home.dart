// lib/day34/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/day34/view/login/login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await PreferenceHandler.removeLogin();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<String?>(
          future: PreferenceHandler.getToken(),
          builder: (context, snapshot) {
            final token = snapshot.data ?? 'Token tidak ditemukan';
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login Berhasil!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Token Anda:', style: TextStyle(fontSize: 16)),
                  Text(token, textAlign: TextAlign.center),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
