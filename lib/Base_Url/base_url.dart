import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrl {
  /// 🔥 Localhost IP
  static const String machineHost = "127.0.0.1";

  /// Android Emulator special IP
  static const String emulatorHost = "10.0.2.2";

  /// iOS simulator / local
  static const String localhost = "127.0.0.1";

  /// 🔹 Change this manually if needed
  /// true = using real phone
  /// false = using emulator
  static const bool useRealDevice = false;

  static String get baseUrl {
    if (Platform.isAndroid) {
      final host = useRealDevice ? machineHost : emulatorHost;
      return "http://$host:8000/api/";
    } else {
      return "http://$emulatorHost:8000/api/";
    }
  }

  static String get loginUrl => "${baseUrl}login";
  static String get registerUrl => "${baseUrl}register/users";
  static String get logoutUrl => "${baseUrl}logout";
  static String get profileUrl => "${baseUrl}profile";
  static String get updateProfileUrl => "${baseUrl}profile/update";
  static String get productUrl => "${baseUrl}products";
  static String get wishlistUrl => "${baseUrl}wishlists";
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
      if (Platform.isAndroid && !useRealDevice) {
        result = result
            .replaceAll("localhost", emulatorHost)
            .replaceAll("127.0.0.1", emulatorHost);
      }
      return result;
    }

    // Remove leading slash
    if (result.startsWith("/")) {
      result = result.substring(1);
    }

    final host = Platform.isAndroid
        ? (useRealDevice ? machineHost : emulatorHost)
        : localhost;

    final storageRoot = "http://$host:8000/storage/";

    if (result.startsWith("storage/")) {
      result = result.replaceFirst("storage/", "");
    }

    if (result.startsWith("$folder/")) {
      return "$storageRoot$result";
    }

    return "$storageRoot$folder/$result";
  }
}
