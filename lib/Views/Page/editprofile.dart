import 'dart:convert';
import 'dart:io';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController profileController = Get.find();
  File? _image;
  final _formKey = GlobalKey<FormState>();
  final Color kMainColor = const Color.fromARGB(255, 227, 207, 54);

  bool _isSaving = false;

  // Controllers
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;

  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController(text: profileController.firstName.value);
    _lastnameController = TextEditingController(text: profileController.lastName.value);
    _emailController = TextEditingController(text: profileController.email.value);
    _phoneController = TextEditingController(text: profileController.phone.value);
    _birthdayController = TextEditingController(text: profileController.birthday.value);
    _gender = profileController.gender.value;
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final token = await BaseUrl.getToken();
      if (token == null) throw Exception("Authentication token not found");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(BaseUrl.updateProfileUrl),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Text fields
      request.fields['first_name'] = _firstnameController.text.trim();
      request.fields['last_name'] = _lastnameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['phone'] = _phoneController.text.trim();
      request.fields['gender'] = _gender;
      request.fields['date_of_birth'] = _birthdayController.text.trim();

      // Image file
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await profileController.fetchProfile();
        if (mounted) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: 'Profile updated successfully!',
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.pop(context, true);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Failed to update profile");
      }
    } catch (e) {
      if (mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: e.toString().replaceAll('Exception: ', ''),
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    final file = await profileController.uploadImageFromGallery();
    if (file != null) {
      setState(() {
        _image = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 207, 54),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 227, 207, 54),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset("icons/back.png", width: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfileImage(),
                const SizedBox(height: 30),
                const _SectionHeader(title: "Personal Information"),
                const SizedBox(height: 15),
                _buildTextField("First Name", _firstnameController, Icons.person_outline),
                _buildTextField("Last Name", _lastnameController, Icons.person_outline),
                _buildTextField("Email Address", _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                _buildTextField("Phone Number", _phoneController, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 20),
                const _SectionHeader(title: "Others"),
                const SizedBox(height: 15),
                _buildGenderPicker("Gender"),
                const SizedBox(height: 15),
                _buildDatePicker("Birthday", _birthdayController, Icons.cake_outlined),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Obx(() => CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (profileController.imageUrl.value.isNotEmpty
                        ? NetworkImage(profileController.imageUrl.value)
                        : null) as ImageProvider?,
                child: _image == null && profileController.imageUrl.value.isEmpty
                    ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                    : null,
              )),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: kMainColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 10, 24),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: kMainColor, onPrimary: Colors.black, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter your $label' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPicker(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.wc, color: Colors.black54),
              const SizedBox(width: 12),
              const Text("Gender", style: TextStyle(color: Colors.black54, fontSize: 13)),
              const Spacer(),
              DropdownButton<String>(
                value: _gender,
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
                items: <String>['Male', 'Female', 'Other'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}
