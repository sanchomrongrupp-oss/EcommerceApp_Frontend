import 'dart:convert';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:demo_interview/Controllers/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class FilterProduct extends StatefulWidget {
  const FilterProduct({super.key});

  @override
  State<FilterProduct> createState() => _FilterProductState();
}

class _FilterProductState extends State<FilterProduct> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _category;
  final WishlistController wishlistController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get category from arguments
    final String? category =
        ModalRoute.of(context)!.settings.arguments as String?;
    if (_category != category) {
      _category = category;
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? token = await BaseUrl.getToken();
      String url = BaseUrl.productUrl;

      if (_category != null && _category != "More" && _category != "All") {
        url = "$url?category=${_category!.toLowerCase()}&per_page=100";
      } else {
        url = "$url?per_page=100";
      }

      debugPrint("Fetching filtered products from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token ?? ""}',
          'Accept': 'application/json',
        },
      );

      debugPrint("Filter Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint("Filter Response: $data");

        setState(() {
          // Robustly extract product list (matching home.dart logic)
          final dynamic rawProducts = data['data'] ?? data['products'] ?? data;
          List<dynamic> newProducts = [];
          if (rawProducts is List) {
            newProducts = rawProducts;
          } else if (rawProducts is Map && rawProducts['data'] is List) {
            newProducts = rawProducts['data'];
          }

          _products = newProducts;
          _isLoading = false;
        });
      } else {
        debugPrint(
          "Error fetching products: ${response.statusCode} - ${response.body}",
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Catch error fetching products: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String categoryTitle = _category ?? "Filter Product";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 227, 207, 54),
        elevation: 0,
      ),
      backgroundColor:
          Colors.grey[100], // Brighter background for better contrast
      body: SafeArea(
        child: _isLoading
            ? ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 12,
                ),
                itemCount: 10,
                itemBuilder: (context, index) => _buildProductSkeleton(),
              )
            : RefreshIndicator(
                onRefresh: _fetchProducts,
                color: const Color.fromARGB(255, 227, 207, 54),
                child: _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No products found",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 12,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return buildProductCard(_products[index], index);
                        },
                      ),
              ),
      ),
    );
  }

  void _navigateToProductDetail(dynamic product, String heroTag) {
    Map<String, dynamic> productWithTag = Map.from(product);
    productWithTag['heroTag'] = heroTag;

    Navigator.pushNamed(
      context,
      BaseRoute.productDetail,
      arguments: productWithTag,
    );
  }

  Widget buildProductCard(dynamic product, int index) {
    final String title =
        product['title']?.toString() ??
        product['name']?.toString() ??
        'Product Name';
    final String price =
        product['price']?.toString() ??
        product['base_price']?.toString() ??
        '0.00';
    final String? imageUrl =
        product['image']?.toString() ?? product['image_url']?.toString();
    final String fullImageUrl = BaseUrl.getFullImageUrl(imageUrl);
    final String heroTag = 'filter_product_${product['id'] ?? title}_$index';
    final String? id = product['id']?.toString() ?? product['_id']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToProductDetail(product, heroTag),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- IMAGE SECTION ---
                Hero(
                  tag: heroTag,
                  child: Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      image: fullImageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(fullImageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: fullImageUrl.isEmpty
                        ? Icon(Icons.image, size: 40, color: Colors.grey[300])
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // --- INFO SECTION ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                wishlistController.toggleFavorite(product),
                            child: Obx(() {
                              final bool isFav = wishlistController.isFavorite(
                                id,
                              );
                              return CircleAvatar(
                                backgroundColor: Colors.grey[100],
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border_outlined,
                                  color: isFav ? Colors.red : Colors.grey[400],
                                  size: 20,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _category ?? "Category",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$$price",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 227, 207, 54),
                            ),
                          ),
                          Row(
                            children: [
                              _buildActionIcon(
                                label: "Cart",
                                color: Colors.green,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  BaseRoute.addToCart,
                                  arguments: product,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildActionIcon(
                                label: "Buy",
                                color: Colors.deepOrange,
                                onTap: () =>
                                    _navigateToProductDetail(product, heroTag),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: color)),
      ),
    );
  }

  Widget _buildProductSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(height: 18, width: 120, color: Colors.white),
                        Container(
                          height: 35,
                          width: 35,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 80, color: Colors.white),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(height: 22, width: 70, color: Colors.white),
                        Row(
                          children: [
                            Container(
                              height: 30,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 30,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
