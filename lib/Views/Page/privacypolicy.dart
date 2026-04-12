import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Last Updated: February 9, 2026",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),
            _buildSection(
              "1. Information We Collect",
              "We collect information that you provide directly to us, such as when you create an account, make a purchase, or communicate with our support team. This includes your name, email address, phone number, and shipping address.",
            ),
            _buildSection(
              "2. How We Use Your Information",
              "The information we collect is used to process your orders, improve our services, and communicate with you about promotions or updates. We do not sell your personal data to third parties.",
            ),
            _buildSection(
              "3. Data Protection",
              "We implement a variety of security measures to maintain the safety of your personal information. Your sensitive data is encrypted and stored in secure servers protected by industry-standard firewalls.",
            ),
            _buildSection(
              "4. Cookies Policy",
              "Our application uses cookies to enhance your shopping experience, such as remembering items in your cart and analyzing traffic patterns to optimize performance.",
            ),
            _buildSection(
              "5. Your Rights",
              "You have the right to access, update, or delete your personal information at any time. You can do this through your account settings or by contacting our support team.",
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "© 2026 SHOPING. All Rights Reserved.",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
      padding: const EdgeInsets.only(bottom: 30),
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
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
