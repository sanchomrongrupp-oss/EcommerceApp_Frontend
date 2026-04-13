import 'dart:convert';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CartController extends GetxController {
  var cartItems = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // No need to fetch here, fetch when MainScreen is ready or after Profile is loaded
  }

  Future<void> fetchCart() async {
    final ProfileController profileController = Get.find();
    
    // Ensure profile is loaded first to get the user ID
    if (profileController.userId.isEmpty) {
      await profileController.fetchProfile();
    }
    
    final String userId = profileController.userId.value;
    if (userId.isEmpty) {
      debugPrint("Could not find user_id for cart");
      return;
    }

    isLoading.value = true;
    try {
      final String? token = await BaseUrl.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse(BaseUrl.cartUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final dynamic rawItems = data['data'] ?? data['carts'] ?? data;
        if (rawItems is List) {
          cartItems.value = rawItems;
        }
      } else if (response.statusCode == 401) {
        BaseUrl.handleUnauthorized();
      }
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart({
    required String productId,
    required int qty,
    String? color,
    String? size,
  }) async {
    final String? token = await BaseUrl.getToken();
    if (token == null) {
      Get.snackbar("Error", "Please login first", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final ProfileController profileController = Get.find();
    final String userId = profileController.userId.value;
    
    if (userId.isEmpty) {
      Get.snackbar("Error", "User data not loaded. Please try again.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final Map<String, dynamic> body = {
        'user_id': userId,
        'product_id': productId,
        'qty': qty,
        'color': color ?? "",
        'size': size ?? "",
      };

      final response = await http.post(
        Uri.parse(BaseUrl.cartUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Added to cart successfully",
            backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
        await fetchCart();
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", errorData['message'] ?? "Failed to add to cart",
            backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint("Error adding to cart: $e");
      Get.snackbar("Error", "Something went wrong",
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateQuantity(String cartId, int newQty) async {
    final String? token = await BaseUrl.getToken();
    if (token == null) return;

    final indexToUpdate = cartItems.indexWhere((item) =>
        (item['id']?.toString() ?? item['_id']?.toString()) == cartId);
    
    int? oldQty;
    if (indexToUpdate != -1) {
      oldQty = int.tryParse(cartItems[indexToUpdate]['qty']?.toString() ?? "1");
      cartItems[indexToUpdate]['qty'] = newQty;
      cartItems.refresh();
    }

    try {
      final response = await http.put(
        Uri.parse("${BaseUrl.cartUrl}/$cartId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'qty': newQty}),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        if (indexToUpdate != -1 && oldQty != null) {
          cartItems[indexToUpdate]['qty'] = oldQty;
          cartItems.refresh();
        }
        await fetchCart();
      }
    } catch (e) {
      debugPrint("Error updating cart quantity: $e");
      if (indexToUpdate != -1 && oldQty != null) {
        cartItems[indexToUpdate]['qty'] = oldQty;
        cartItems.refresh();
      }
    }
  }

  Future<void> removeFromCart(String cartId) async {
    final String? token = await BaseUrl.getToken();
    if (token == null) return;

    final indexToRemove = cartItems.indexWhere((item) =>
        (item['id']?.toString() ?? item['_id']?.toString()) == cartId);
    
    dynamic removedItem;
    if (indexToRemove != -1) {
      removedItem = cartItems.removeAt(indexToRemove);
    }

    try {
      final response = await http.delete(
        Uri.parse("${BaseUrl.cartUrl}/$cartId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (removedItem != null) {
          cartItems.insert(indexToRemove, removedItem);
        }
        await fetchCart();
      }
    } catch (e) {
      debugPrint("Error removing from cart: $e");
      if (removedItem != null && indexToRemove != -1) {
        cartItems.insert(indexToRemove, removedItem);
      }
    }
  }
}
