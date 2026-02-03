// ignore_for_file: prefer_const_constructors, camel_case_types, prefer_const_literals_to_create_immutables, unused_element, prefer_final_fields, unused_field, override_on_non_overriding_member, use_build_context_synchronously, non_constant_identifier_names

import 'package:demo_interview/constant.dart';
import 'package:flutter/material.dart';
import 'package:demo_interview/Views/Page/signin.dart';

class Singup extends StatefulWidget {
  const Singup({super.key});
  @override
  State<Singup> createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  String? _selectedGender;
  bool loading = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController(),
      _lastNameController = TextEditingController(),
      _dateOfBirthController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController(),
      _confirmPasswordController = TextEditingController();

  void _registerUser() async {
    // Mock API call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Signin()),
        (route) => false,
      );
    }
  }

  Widget buildInputField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: hintText,
          hintStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SHOPING",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      ),
      backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      body: Form(
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: ListView(
            children: [
              Column(
                children: [
                  Text(
                    'SIGNUP YOUR ACCOUNT',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: buildInputField(
                          hintText: 'First Name',
                          controller: _firstNameController,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: buildInputField(
                          hintText: 'Last Name',
                          controller: _lastNameController,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(), // Adds border
                        filled: true,
                        fillColor:
                            Colors.white, // Optional: adds background color
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      hint: Text(
                        "Select Gender",
                        style: TextStyle(color: Colors.black),
                      ),
                      initialValue: _selectedGender,
                      items: ['Male', 'Female']
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Please select a gender'
                          : null, // Optional validation
                    ),
                  ),
                  buildInputField(
                    hintText: 'Date of Birth',
                    controller: _dateOfBirthController,
                  ),
                  buildInputField(
                    hintText: 'Email',
                    controller: _emailController,
                  ),
                  buildInputField(
                    hintText: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  buildInputField(
                    hintText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  kElevatedButton('Sign Up', () {
                    if (_formkey.currentState!.validate()) {
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Password do not match')),
                        );
                        return;
                      }
                      setState(() {
                        loading = !loading;
                        _registerUser();
                      });
                    }
                  }),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Signin()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: Text("Sign in"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
