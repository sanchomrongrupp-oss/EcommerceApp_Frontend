import 'dart:convert';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WishlistController extends GetxController {
  var wishlistItems = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetching will be handled by MainScreen
  }

  Future<void> fetchWishlist() async {
     final ProfileController profileController = Get.find();
    
    // Ensure profile is loaded first to get the user ID
    if (profileController.userId.isEmpty) {
      await profileController.fetchProfile();
    }
    
    final String userId = profileController.userId.value;
    if (userId.isEmpty) {
      debugPrint("Could not find user_id for wishlist");
      return;
    }

    isLoading.value = true;
    try {
      final String? token = await BaseUrl.getToken();
      if (token == null) return;

      final response = await http
          .get(
            Uri.parse("${BaseUrl.wishlistUrl}/user/$userId"),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final dynamic rawItems = data['data'] ?? data['wishlists'] ?? data;
        if (rawItems is List) {
          wishlistItems.value = rawItems;
        }
      } else if (response.statusCode == 401) {
        BaseUrl.handleUnauthorized();
      }
    } catch (e) {
      debugPrint("Error fetching wishlist: $e");
    } finally {
      isLoading.value = false;
    }
  }

  bool isFavorite(String? productId) {
    if (productId == null) return false;
    return wishlistItems.any((item) {
      final String? id =
          item['product_id']?.toString() ??
          item['id']?.toString() ??
          item['_id']?.toString();
      return id == productId;
    });
  }

  Future<void> toggleFavorite(dynamic product) async {
    final String? productId =
        product['id']?.toString() ?? product['_id']?.toString();
    if (productId == null) return;

    final String? token = await BaseUrl.getToken();
    final bool currentlyFavorite = isFavorite(productId);

    try {
      if (currentlyFavorite) {
        final itemToRemove = wishlistItems.firstWhere((item) {
          final String? id =
              item['product_id']?.toString() ??
              item['id']?.toString() ??
              item['_id']?.toString();
          return id == productId;
        }, orElse: () => null);

        if (itemToRemove != null) {
          final String? deleteId =
              itemToRemove['_id']?.toString() ?? itemToRemove['id']?.toString();

          if (deleteId == null || deleteId == productId) {
            await fetchWishlist();
            return;
          }

          wishlistItems.remove(itemToRemove);
          final response = await http
              .delete(
                Uri.parse("${BaseUrl.wishlistUrl}/$deleteId"),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                },
              )
              .timeout(const Duration(seconds: 60));

          if (response.statusCode != 200 && response.statusCode != 204) {
            await fetchWishlist();
          }
        }
      } else {
        final ProfileController profileController = Get.find();
        final String userId = profileController.userId.value;
        if (userId.isEmpty) return;

        wishlistItems.add({'product_id': productId, ...product});

        final Map<String, dynamic> body = {
          'user_id': userId,
          'product_id': productId,
        };

        final response = await http
            .post(
              Uri.parse(BaseUrl.wishlistUrl),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 60));

        if (response.statusCode != 200 && response.statusCode != 201) {
          await fetchWishlist();
        } else {
          await fetchWishlist();
        }
      }
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
      await fetchWishlist();
    }
  }

  void removeFromWishlist(String productId, int index) async {
    final String? token = await BaseUrl.getToken();

    if (index >= 0 && index < wishlistItems.length) {
      final itemToRemove = wishlistItems[index];
      final String? deleteId =
          itemToRemove['_id']?.toString() ?? itemToRemove['id']?.toString();

      wishlistItems.removeAt(index);

      if (deleteId == null || deleteId == productId) {
        await fetchWishlist();
        return;
      }

      try {
        final response = await http
            .delete(
              Uri.parse("${BaseUrl.wishlistUrl}/$deleteId"),
              headers: {
                'Authorization': 'Bearer ${token ?? ""}',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 60));

        if (response.statusCode != 200 && response.statusCode != 204) {
          await fetchWishlist();
        }
      } catch (e) {
        debugPrint("Error removing from wishlist: $e");
        await fetchWishlist();
      }
    }
  }
}
