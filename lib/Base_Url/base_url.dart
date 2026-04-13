import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_interview/Route/route_constants.dart';

class BaseUrl {
  static String get baseUrl {
    return "https://ecommerceapp-backend-a8om.onrender.com/api/";
  }

  static String get loginUrl => "${baseUrl}login";
  static String get registerUrl => "${baseUrl}register/users";
  static String get logoutUrl => "${baseUrl}logout";
  static String get profileUrl => "${baseUrl}profile";
  static String get updateProfileUrl => "${baseUrl}profile/update";
  static String get productUrl => "${baseUrl}products";
  static String get hotProductUrl => "${baseUrl}hot-products";
  static String get categoryUrl => "${baseUrl}categories";
  static String get wishlistUrl => "${baseUrl}wishlists";
  static String get cartUrl => "${baseUrl}carts";
  static String get changePasswordUrl => "${baseUrl}change-password";
  static String get paywayCreatePaymentUrl => "${baseUrl}aba-v2/init";
  static String get paywayRenderCheckoutUrl => "${baseUrl}aba-v2/redirect";

  // ================= TOKEN =================

  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<bool> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('token');
  }

  // ================= IMAGE URL =================

  static String getFullImageUrl(String? path, {String folder = "products"}) {
    if (path == null || path.isEmpty) return "";

    String result = path.trim();

    // 🔹 If already full URL
    if (result.startsWith("http")) {
      return result;
    }

    // Remove leading slash
    if (result.startsWith("/")) {
      result = result.substring(1);
    }

    final storageRoot =
        "https://ecommerceapp-backend-a8om.onrender.com/storage/";

    // 🔹 If already has storage/ prefix
    if (result.startsWith("storage/")) {
      result = result.replaceFirst("storage/", "");
    }

    // 🔹 If already has folder/ prefix
    if (result.startsWith("$folder/")) {
      return "$storageRoot$result";
    }

    // Default to folder/path
    return "$storageRoot$folder/$result";
  }

  // ================= UNAUTHORIZED HANDLE =================

  static void handleUnauthorized() async {
    // Clear token
    await removeToken();

    // Reset GetX states globally to prevent data leaking
    // Using simple Get.offAll ensures a fresh start,
    // but we can also manually delete core controllers if needed.
    // To avoid circular dependencies, we use their registered names or dynamic deletion.

    // Redirect to signin using route constant
    Get.offAllNamed(RouteConstants.signin);

    // Notify user
    Get.snackbar(
      "Session Expired",
      "Your session has expired. Please login again.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.lock_clock_outlined, color: Colors.white),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
    );
  }
}
