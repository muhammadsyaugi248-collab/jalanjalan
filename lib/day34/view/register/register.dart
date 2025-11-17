import 'package:flutter/material.dart';
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/day34/view/login/login.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color kPrimaryColor = Colors.black;

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _trainingController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedBatch;
  bool _isLoading = false;
  bool _obscureText = true;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _trainingController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ============================
  //   HANDLE REGISTER API
  // ============================
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(Endpoint.register),
        body: {
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "batch": _selectedBatch ?? "",
          "training_id": _trainingController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonRes["token"] != null) {
        await PreferenceHandler.saveLogin(true);
        await PreferenceHandler.saveToken(jsonRes["token"]);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonRes["message"] ?? "Registrasi Berhasil"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          );
        }
      } else {
        throw Exception(jsonRes["message"] ?? "Registrasi gagal");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  // ============================
  //            UI
  // ============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 3, color: Colors.black),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(6, 6)),
                  ],
                ),

                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // BACK TO LOGIN
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back, size: 28),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // LOGO
                      Container(width: 60, height: 60, color: Colors.black),

                      const SizedBox(height: 14),

                      const Text(
                        "CREATE ACCOUNT",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),

                      const Text(
                        "FILL YOUR DETAILS BELOW",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),

                      const SizedBox(height: 28),

                      // ================= NAME =================
                      _buildLabel("NAME"),
                      _buildBlackBorderInput(
                        controller: _nameController,
                        validator: (v) => v!.isEmpty ? "Nama diperlukan" : null,
                      ),

                      const SizedBox(height: 20),

                      // ================= EMAIL =================
                      _buildLabel("EMAIL"),
                      _buildBlackBorderInput(
                        controller: _emailController,
                        validator: (v) =>
                            v!.isEmpty ? "Email diperlukan" : null,
                      ),

                      const SizedBox(height: 20),

                      // ================= BATCH (Dropdown) =================
                      _buildLabel("BATCH"),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedBatch,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "1",
                              child: Text("Batch 1"),
                            ),
                            DropdownMenuItem(
                              value: "2",
                              child: Text("Batch 2"),
                            ),
                            DropdownMenuItem(
                              value: "3",
                              child: Text("Batch 3"),
                            ),
                            DropdownMenuItem(
                              value: "4",
                              child: Text("Batch 4"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedBatch = value);
                          },
                          validator: (value) =>
                              value == null ? "Batch harus dipilih" : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= TRAINING ID =================
                      _buildLabel("TRAINING ID"),
                      _buildBlackBorderInput(
                        controller: _trainingController,
                        validator: (v) =>
                            v!.isEmpty ? "Training ID diperlukan" : null,
                      ),

                      const SizedBox(height: 20),

                      // ================= PASSWORD =================
                      _buildLabel("PASSWORD"),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscureText,
                                validator: (v) =>
                                    v!.isEmpty ? "Password diperlukan" : null,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() => _obscureText = !_obscureText);
                              },
                              child: Container(
                                color: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Text(
                                  _obscureText ? "SHOW" : "HIDE",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ========== BUTTON CREATE ACCOUNT ==========
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  "CREATE ACCOUNT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ========== LOGIN LINK ==========
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "SIGN IN",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================
  // WIDGET HELPERS
  // ============================

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildBlackBorderInput({
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
