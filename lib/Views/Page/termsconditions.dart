import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kMainColor = Color.fromARGB(255, 227, 207, 54);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset("icons/back.png", width: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Last Updated: February 2026",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSection(
              "1. Introduction",
              "Welcome to SHOPING. These terms and conditions outline the rules and regulations for the use of our mobile application. By accessing this app, we assume you accept these terms and conditions. Do not continue to use SHOPING if you do not agree to all of the terms and conditions stated on this page.",
            ),
            _buildSection(
              "2. Account Security",
              "Users are responsible for maintaining the confidentiality of their account and password. You agree to accept responsibility for all activities that occur under your account. We reserve the right to refuse service, terminate accounts, or cancel orders at our sole discretion.",
            ),
            _buildSection(
              "3. Privacy Policy",
              "Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information. By using our app, you agree to the collection and use of information in accordance with our policy.",
            ),
            _buildSection(
              "4. Intellectual Property",
              "Unless otherwise stated, SHOPING and/or its licensors own the intellectual property rights for all material on this app. All intellectual property rights are reserved. You may access this for your own personal use subjected to restrictions set in these terms and conditions.",
            ),
            _buildSection(
              "5. User Responsibilities",
              "You must not:\n• Republish material from SHOPING\n• Sell, rent, or sub-license material from SHOPING\n• Reproduce, duplicate, or copy material from SHOPING\n• Redistribute content from SHOPING",
            ),
            _buildSection(
              "6. Limitation of Liability",
              "In no event shall SHOPING, nor any of its officers, directors, and employees, be held liable for anything arising out of or in any way connected with your use of this app. SHOPING shall not be held liable for any indirect, consequential, or special liability arising out of your use of this app.",
            ),
            _buildSection(
              "7. Governing Law",
              "These terms will be governed by and interpreted in accordance with the laws of the jurisdiction in which SHOPING operates, and you submit to the non-exclusive jurisdiction of the state and federal courts located in said jurisdiction for the resolution of any disputes.",
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "© 2026 SHOPING. All Rights Reserved.",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
