// lib/day34/view/register/create_account_screen.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jalanjalan/day34/constant/endpoint.dart';
import 'package:jalanjalan/day34/preferens/preference_handler.dart';
import 'package:jalanjalan/day34/services/api_training.dart';
import 'package:jalanjalan/day34/views/absensi/absensi.dart';
import 'package:jalanjalan/day34/views/login/login.dart';

const Color kPrimaryColor = Colors.black;

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  // controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _trainingController =
      TextEditingController(); // optional if you keep manual training id input
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // dropdown data
  List<Map<String, dynamic>> _trainings = [];
  List<Map<String, dynamic>> _batches = [];

  int? _selectedTrainingId;
  String? _selectedBatchId;
  String? _selectedGender; // "L" atau "P"

  bool _isLoading = false; // when registering
  bool _isFetching = true; // when fetching trainings/batches
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

    _fetchInitialData();
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

  Future<void> _fetchInitialData() async {
    setState(() => _isFetching = true);
    try {
      final trainings = await TrainingAPI.getTraining();
      final batches = await TrainingAPI.getBatch();
      setState(() {
        _trainings = trainings;
        _batches = batches;
      });
      log(
        'Trainings fetched: ${_trainings.length}, batches: ${_batches.length}',
      );
    } catch (e) {
      log('Error fetching initial data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isFetching = false);
    }
  }

  // REGISTER
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih jenis kelamin')));
      return;
    }
    if (_selectedTrainingId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih training')));
      return;
    }
    if (_selectedBatchId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih batch')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(Endpoint.register);
      final body = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "training_id": _selectedTrainingId.toString(),
        "batch_id": _selectedBatchId ?? "",
        "jenis_kelamin": _selectedGender ?? "",
        "password": _passwordController.text.trim(),
        "password_confirmation": _passwordController.text.trim(),
      };

      log('Register body: $body');

      final response = await http.post(
        uri,
        headers: {"Accept": "application/json"},
        body: body,
      );

      log('REGISTER STATUS: ${response.statusCode} BODY: ${response.body}');

      dynamic jsonRes;
      try {
        jsonRes = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Response server tidak valid: ${response.body}');
      }

      final status = response.statusCode;
      if (status == 200 || status == 201) {
        final token = jsonRes is Map && jsonRes['data'] != null
            ? jsonRes['data']['token']?.toString()
            : null;
        final message = (jsonRes is Map && jsonRes['message'] != null)
            ? jsonRes['message'].toString()
            : 'Registrasi berhasil';

        if (token != null && token.isNotEmpty) {
          await PreferenceHandler.saveToken(token);
          await PreferenceHandler.saveLogin(true);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.green),
            );
            // Auto-login: ke HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$message (silakan login)'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            );
          }
        }
      } else {
        // jika server mengembalikan errors (validation), tampilkan detail
        String errMsg = 'Registrasi gagal. Status: $status';
        if (jsonRes is Map) {
          if (jsonRes['message'] != null)
            errMsg = jsonRes['message'].toString();
          else if (jsonRes['errors'] != null) {
            final errors = jsonRes['errors'];
            if (errors is Map) {
              final firstKey = errors.keys.isNotEmpty
                  ? errors.keys.first
                  : null;
              if (firstKey != null) {
                final firstErr = errors[firstKey];
                if (firstErr is List && firstErr.isNotEmpty)
                  errMsg = firstErr.first.toString();
                else
                  errMsg = firstErr.toString();
              }
            } else {
              errMsg = errors.toString();
            }
          }
        }
        throw Exception(errMsg);
      }
    } catch (e) {
      final err = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
        );
      }
      log('register error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Center(
          child: _isFetching
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
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
                            Container(
                              width: 60,
                              height: 60,
                              color: Colors.black,
                            ),
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
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // NAME
                            _buildLabel("NAME"),
                            _buildBlackBorderInput(
                              controller: _nameController,
                              validator: (v) =>
                                  v!.isEmpty ? "Nama diperlukan" : null,
                            ),
                            const SizedBox(height: 20),

                            // EMAIL
                            _buildLabel("EMAIL"),
                            _buildBlackBorderInput(
                              controller: _emailController,
                              validator: (v) =>
                                  v!.isEmpty ? "Email diperlukan" : null,
                            ),
                            const SizedBox(height: 20),

                            // GENDER
                            _buildLabel("GENDER"),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedGender,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: InputBorder.none,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "L",
                                    child: Text("Laki-laki"),
                                  ),
                                  DropdownMenuItem(
                                    value: "P",
                                    child: Text("Perempuan"),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _selectedGender = v),
                                validator: (v) =>
                                    v == null ? "Pilih jenis kelamin" : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // BATCH dropdown dynamic
                            _buildLabel("BATCH"),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedBatchId,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: InputBorder.none,
                                ),
                                items: _batches.map((b) {
                                  final id = b['id']?.toString() ?? '';
                                  final label =
                                      b['batch_ke']?.toString() ?? 'Batch $id';
                                  return DropdownMenuItem<String>(
                                    value: id,
                                    child: Text(label),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedBatchId = v),
                                validator: (v) =>
                                    v == null ? "Batch harus dipilih" : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // TRAINING
                            _buildLabel("TRAINING"),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: _selectedTrainingId,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: InputBorder.none,
                                ),
                                items: _trainings.map((t) {
                                  final id = t['id'] is int
                                      ? t['id'] as int
                                      : int.tryParse(t['id'].toString()) ?? 0;
                                  final title =
                                      t['title']?.toString() ?? 'Training $id';
                                  return DropdownMenuItem<int>(
                                    value: id,
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedTrainingId = v),
                                validator: (v) =>
                                    v == null ? "Training harus dipilih" : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // PASSWORD
                            _buildLabel("PASSWORD"),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscureText,
                                      validator: (v) => v!.isEmpty
                                          ? "Password diperlukan"
                                          : null,
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
                                    onTap: () => setState(
                                      () => _obscureText = !_obscureText,
                                    ),
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

                            // BUTTON
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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

                            // LOGIN LINK
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account? "),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignInScreen(),
                                    ),
                                  ),
                                  child: const Text(
                                    "SIGN IN",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
