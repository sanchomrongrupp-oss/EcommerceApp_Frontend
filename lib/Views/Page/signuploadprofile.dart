import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:demo_interview/constant.dart';
import 'package:http/http.dart' as http;

class SignUploadProfile extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const SignUploadProfile({super.key, this.userData});

  @override
  State<SignUploadProfile> createState() => _SignUploadProfileState();
}

class _SignUploadProfileState extends State<SignUploadProfile> {
  File? _image;
  bool _loading = false;
  final Color kMainColor = const Color.fromARGB(255, 227, 207, 54);

  @override
  void initState() {
    super.initState();
    // 🕵️ Check this in your debug console to see the exact structure
    debugPrint("RECEIVED USER DATA: ${widget.userData}");
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Select Image Source',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAndContinue() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a profile photo first.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final token = await BaseUrl.getToken();
      debugPrint("Using Token: $token");
      if (token == null) {
        throw Exception("You must be logged in to upload a profile picture.");
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(BaseUrl.updateProfileUrl),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image', // Assuming the backend field is 'profile_image'
          _image!.path,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Upload Success: ${response.body}");
        _navigateToDashboard();
      } else {
        setState(() => _loading = false);
        debugPrint("Upload Fail: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Upload failed (${response.statusCode}). Please try again.",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      debugPrint("Upload Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
    }
  }

  void _navigateToDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      BaseRoute.dashboard,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    "WELCOME, ${widget.userData?['first_name']?.toString().toUpperCase() ?? widget.userData?['user']?['first_name']?.toString().toUpperCase() ?? widget.userData?['data']?['first_name']?.toString().toUpperCase() ?? 'FRIEND'}!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "ADD A PHOTO",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add a profile photo so your friends can recognize you",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Profile Image Section
            _buildProfileImagePreview(),

            const Spacer(),

            // Action Buttons Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                      : kElevatedButton(
                          label: "SAVE & CONTINUE",
                          onPressed: _uploadAndContinue,
                          backgroundColor: Colors.blue,
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _navigateToDashboard,
                    child: const Text(
                      "Skip for now",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImagePreview() {
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse effect or Outer ring
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.05),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: CircleAvatar(
                radius: 120,
                backgroundColor: Colors.grey[200],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? Icon(
                        Icons.person_add_rounded,
                        size: 100,
                        color: Colors.grey[400],
                      )
                    : null,
              ),
            ),
          ),

          // Camera overlay button
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
