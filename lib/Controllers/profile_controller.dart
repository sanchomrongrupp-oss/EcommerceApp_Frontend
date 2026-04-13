import 'dart:convert';
import 'dart:io';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  var firstName = "".obs;
  var lastName = "".obs;
  var userId = "".obs;
  var imageUrl = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var gender = "Male".obs;
  var birthday = "".obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  String get userName => "${firstName.value} ${lastName.value}".trim().isEmpty
      ? "User"
      : "${firstName.value} ${lastName.value}".trim();

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      final String? token = await BaseUrl.getToken();
      if (token == null) {
        isLoading(false);
        return;
      }

      final response = await http
          .get(
            Uri.parse(BaseUrl.profileUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final dataRaw = jsonDecode(response.body);
        final userData =
            dataRaw['data']?['user'] ??
            dataRaw['user'] ??
            dataRaw['data'] ??
            dataRaw;

        firstName.value = userData['first_name']?.toString() ?? "";
        lastName.value = userData['last_name']?.toString() ?? "";
        userId.value = userData['id']?.toString() ?? userData['_id']?.toString() ?? "";
        email.value = userData['email']?.toString() ?? "";
        phone.value = userData['phone']?.toString() ?? "";
        gender.value = userData['gender']?.toString() ?? "Male";
        birthday.value = userData['date_of_birth']?.toString() ?? "";

        String? imgPath =
            userData['image_url']?.toString() ??
            userData['profile_image_url']?.toString() ??
            userData['profile_image']?.toString();

        imageUrl.value = BaseUrl.getFullImageUrl(
          imgPath,
          folder: "profile",
        );
      } else if (response.statusCode == 401) {
        BaseUrl.handleUnauthorized();
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> uploadImage(File imageFile) async {
    try {
      final token = await BaseUrl.getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(BaseUrl.updateProfileUrl),
      );
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchProfile();
        return true;
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
    }
    return false;
  }

  Future<File?> uploadImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final success = await uploadImage(file);
      if (success) return file;
    }
    return null;
  }
}
