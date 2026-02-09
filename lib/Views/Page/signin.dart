// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:demo_interview/main.dart';
import 'package:demo_interview/Views/Page/signup.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:demo_interview/constant.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _loading = false;

  Future<void> _signinUser() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      BaseRoute.dashboard,
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  Text(
                    'Sign In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: kInputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!value.contains('@')) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  /// Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: kInputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _isObscure = !_isObscure);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  /// Button / Loading
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : kElevatedButton(
                          label: "Sign In",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _loading = true);
                              _signinUser();
                            }
                          },
                        ),

                  const SizedBox(height: 15),

                  /// Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => Signup()),
                          );
                        },
                        child: const Text("Sign up"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// Social login
                  Column(
                    children: [
                      const Text("Login with"),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton('icons/facebook.png'),
                          const SizedBox(width: 15),
                          _socialButton('icons/communication.png'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String asset) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {},
      child: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: Image.asset(asset, height: 30),
      ),
    );
  }
}
