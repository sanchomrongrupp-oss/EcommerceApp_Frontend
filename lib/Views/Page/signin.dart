// ignore_for_file: prefer_const_constructors, camel_case_types, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, body_might_complete_normally_nullable, unused_import, unused_field, prefer_final_fields, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:demo_interview/main.dart';
import 'package:demo_interview/Views/Page/singup.dart';
import 'package:demo_interview/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  bool _isOuscure = true;
  bool loading = false;
  // bool _isRememberme = true;

  final _formkey = GlobalKey<FormState>();
  TextEditingController _usernameControler = TextEditingController();
  TextEditingController _passwordControler = TextEditingController();
  var sneckBar = SnackBar(content: Text('Longin Success!'));

  void _signinUser() async {
    // Mock API call
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'WELCOME TO SHOPING',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: TextFormField(
                    controller: _usernameControler,
                    decoration: kInputDecoration('Username'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Invalid usrenam';
                      }
                    },
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: TextFormField(
                    controller: _passwordControler,
                    obscureText: _isOuscure,
                    decoration: kInputDecoration('Password'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Invalid Password ';
                      }
                    },
                  ),
                ),
                SizedBox(height: 30),
                kElevatedButton('Sign In', () {
                  if (_formkey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    _signinUser();
                  }
                }),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("You have't account yet !"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Singup()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text("Sing up"),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Login with an account!"),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'icons/facebook.png',
                            height: 45,
                            width: 45,
                          ),
                        ),
                        SizedBox(width: 5),
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'icons/communication.png',
                            height: 45,
                            width: 45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
