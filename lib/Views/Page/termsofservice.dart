import 'package:flutter/material.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

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
          "Terms of Service",
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
              "1. Acceptance of Terms",
              "By using the SHOPING mobile application, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.",
            ),
            _buildSection(
              "2. Account Eligibility",
              "You must be at least 18 years old to create an account and make purchases. You are responsible for all activities that occur under your account credentials.",
            ),
            _buildSection(
              "3. Pricing and Payments",
              "All prices are listed in USD unless otherwise stated. We reserve the right to change prices at any time. Payments are processed securely through our partners.",
            ),
            _buildSection(
              "4. Prohibited Activities",
              "Users may not engage in any activity that interferes with or disrupts the application's functionality, including but not limited to hacking, scraping, or spamming.",
            ),
            _buildSection(
              "5. Termination",
              "We reserve the right to terminate or suspend your account at our sole discretion, without notice, for conduct that we believe violates these terms.",
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
