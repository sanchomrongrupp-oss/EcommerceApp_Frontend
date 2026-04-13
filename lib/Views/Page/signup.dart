// ignore_for_file: prefer_const_constructors

import 'package:demo_interview/main.dart';
import 'package:flutter/material.dart';
import 'package:demo_interview/constant.dart';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedGender;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _registerUser() async {
    try {
      final dateText = _dobController.text.trim();

      final response = await http.post(
        Uri.parse(BaseUrl.registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'gender': _selectedGender,
          'date_of_birth': dateText,
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 60));

      debugPrint("Signup Status: ${response.statusCode}");
      debugPrint("Signup Response: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataRaw = jsonDecode(response.body);
        debugPrint("Signup Success: $dataRaw");

        final data = dataRaw['data'] ?? dataRaw;

        // 🔥 Extract token if available (to auto-login the user for the next step)
        dynamic tokenValue = data['access_token'] ?? dataRaw['access_token'] ?? data['token'];

        if (tokenValue != null) {
          await BaseUrl.saveToken(tokenValue.toString());
        }

        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Account created successfully! Welcome aboard.',
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);

          Navigator.pushNamedAndRemoveUntil(
            context,
            BaseRoute.signUploadProfile,
            (route) => false,
            arguments: data,
          );
        }
      } else {
        setState(() => _loading = false);

        String errorMessage = 'Registration failed';
        if (response.statusCode == 404) {
          errorMessage =
              "The requested endpoint was not found (404). Please check your API URL.";
        } else {
          try {
            final data = jsonDecode(response.body);
            if (data['errors'] != null) {
              final Map<String, dynamic> errors = data['errors'];
              errorMessage = errors.values.first[0].toString();
            } else {
              errorMessage = data['message'] ?? errorMessage;
            }
          } catch (e) {
            errorMessage = 'Server error (${response.statusCode})';
          }
        }

        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Registration Error',
              message: errorMessage,
              contentType: ContentType.failure,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      String errorType = "Error";
      if (e.toString().contains("SocketException")) {
        errorType = "Network Error (DNS/Firewall)";
      } else if (e.toString().contains("TimeoutException")) {
        errorType = "Connection Timeout (Server starting up?)";
      } else if (e.toString().contains("HandshakeException")) {
        errorType = "SSL Handshake Failed (Certificate issue)";
      }

      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'On Snap!',
            message: '$errorType: $e',
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
      debugPrint("Signup Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    'SIGN UP YOUR ACCOUNT',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  /// First & Last Name
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: kInputDecoration(hintText: "First Name"),
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: kInputDecoration(hintText: "Last Name"),
                          validator: (value) =>
                              value!.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Gender
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: kInputDecoration(hintText: "Gender"),
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedGender = value);
                    },
                    validator: (value) =>
                        value == null ? "Select gender" : null,
                  ),

                  const SizedBox(height: 16),

                  /// Date of birth
                  TextFormField(
                    controller: _dobController,
                    decoration: kInputDecoration(
                      hintText: "Date of Birth",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        initialDate: DateTime(2000),
                      );
                      if (date != null) {
                        setState(() {
                          _dobController.text =
                              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 16),

                  /// Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: kInputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Email required";
                      if (!value.contains('@')) return "Invalid email";
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: kInputDecoration(
                      hintText: "Phone",
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Phone required";
                      if (!value.contains('0')) return "Invalid phone";
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: kInputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
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
                    obscureText: _obscureConfirmPassword,
                    decoration: kInputDecoration(
                      hintText: "Confirm Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  /// Button / Loader
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : kElevatedButton(
                          label: "Sign Up",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _loading = true);
                              _registerUser();
                            }
                          },
                        ),

                  const SizedBox(height: 20),

                  /// Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => MainScreen()),
                          );
                        },
                        child: const Text("Sign in"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
