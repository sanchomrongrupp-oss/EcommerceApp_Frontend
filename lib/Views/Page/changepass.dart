// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:demo_interview/constant.dart';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  Future<void> _updatePassword() async {
    setState(() => _loading = true);

    try {
      final String? token = await BaseUrl.getToken();
      final ProfileController profileController = Get.find();
      final String userEmail = profileController.email.value;

      final response = await http
          .post(
            Uri.parse(BaseUrl.changePasswordUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': userEmail,
              'old_password': _currentPasswordController.text,
              'new_password': _newPasswordController.text,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Great Success!',
            message: data['message'] ?? "Password updated successfully!",
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);

        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        BaseUrl.handleUnauthorized();
      } else {
        String msg = data['message'] ?? "Update failed";
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          msg = errors.values.first[0].toString();
        }

        if (!mounted) return;
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Update Failed',
            message: msg,
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      if (!mounted) return;
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'System Error',
          message: e.toString(),
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 227, 207, 54),
              Color.fromARGB(255, 200, 180, 40),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_reset_rounded,
                        size: 80,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Change Password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Your new password must be different from previously used passwords.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 40),

                      // Form Card
                      Card(
                        elevation: 8,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                /// Current Password
                                TextFormField(
                                  controller: _currentPasswordController,
                                  obscureText: _obscureCurrent,
                                  decoration: kInputDecoration(
                                    hintText: "Current Password",
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureCurrent
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () => setState(
                                        () =>
                                            _obscureCurrent = !_obscureCurrent,
                                      ),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value!.isEmpty ? "Required" : null,
                                ),
                                const SizedBox(height: 16),

                                /// New Password
                                TextFormField(
                                  controller: _newPasswordController,
                                  obscureText: _obscureNew,
                                  decoration: kInputDecoration(
                                    hintText: "New Password",
                                    prefixIcon: const Icon(Icons.password),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureNew
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscureNew = !_obscureNew,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.length < 6) {
                                      return "Min 6 characters";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                /// Confirm Password
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirm,
                                  decoration: kInputDecoration(
                                    hintText: "Confirm Password",
                                    prefixIcon: const Icon(
                                      Icons.check_circle_outline,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () => setState(
                                        () =>
                                            _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != _newPasswordController.text) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),

                                /// Action Button
                                _loading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        child: kElevatedButton(
                                          label: "UPDATE PASSWORD",
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _updatePassword();
                                            }
                                          },
                                          icon: Icons.update,
                                          backgroundColor: Colors.black,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
