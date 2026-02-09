// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:demo_interview/Views/Page/signin.dart';
import 'package:demo_interview/constant.dart';

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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedGender;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _registerUser() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Signin()),
      (route) => false,
    );
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
                    'CREATE ACCOUNT',
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
                              "${date.day}/${date.month}/${date.year}";
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
                            MaterialPageRoute(builder: (_) => const Signin()),
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
