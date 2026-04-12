import 'dart:convert';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WishlistController extends GetxController {
  var wishlistItems = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    isLoading.value = true;
    try {
      final token = await BaseUrl.getToken();
      final response = await http.get(
        Uri.parse(BaseUrl.wishlistUrl),
        headers: {
          'Authorization': 'Bearer ${token ?? ""}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final dynamic rawItems = data['data'] ?? data['wishlists'] ?? data;
        if (rawItems is List) {
          wishlistItems.value = rawItems;
        }
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
        // Find the index to remove it from local state immediately for better UX
        final index = wishlistItems.indexWhere((item) {
          final String? id =
              item['product_id']?.toString() ??
              item['id']?.toString() ??
              item['_id']?.toString();
          return id == productId;
        });

        if (index != -1) {
          wishlistItems.removeAt(index);
        }

        final response = await http.delete(
          Uri.parse("${BaseUrl.wishlistUrl}/$productId"),
          headers: {
            'Authorization': 'Bearer ${token ?? ""}',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode != 200 && response.statusCode != 204) {
          // Rollback if failed
          fetchWishlist();
        }
      } else {
        // Add locally first for better UX
        wishlistItems.add({'product_id': productId, ...product});

        final response = await http.post(
          Uri.parse(BaseUrl.wishlistUrl),
          headers: {
            'Authorization': 'Bearer ${token ?? ""}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'product_id': productId}),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          // Rollback if failed
          fetchWishlist();
        } else {
          // Refresh to get correct data from server if needed
          fetchWishlist();
        }
      }
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
      fetchWishlist(); // Refresh to sync on error
    }
  }

  void removeFromWishlist(String productId, int index) async {
    final String? token = await BaseUrl.getToken();

    // Remove locally
    wishlistItems.removeAt(index);

    try {
      final response = await http.delete(
        Uri.parse("${BaseUrl.wishlistUrl}/$productId"),
        headers: {
          'Authorization': 'Bearer ${token ?? ""}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        fetchWishlist(); // Rollback
      }
    } catch (e) {
      debugPrint("Error removing from wishlist: $e");
      fetchWishlist();
    }
  }
}
