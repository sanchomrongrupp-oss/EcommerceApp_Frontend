import 'dart:convert';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Controllers/wishlist_controller.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late PageController _pageController;
  Map<String, dynamic>? product;
  String? heroTag;

  int _currentPage = 0;
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  int _quantity = 1;

  final WishlistController wishlistController = Get.find();

  List<String> _colors = [];
  List<String> _sizes = [];
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (product == null) {
      product =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (product != null) {
        heroTag = product!['heroTag']?.toString();
        // Extract images
        _images = [];
        final String? mainImage =
            product!['image']?.toString() ??
            product!['image_url']?.toString() ??
            product!['product_image']?.toString();
        if (mainImage != null && mainImage.isNotEmpty) {
          _images.add(mainImage);
        }

        // If 'images' is a list in JSON, add them too
        if (product!['images'] is List) {
          for (var img in product!['images']) {
            if (img.toString().isNotEmpty &&
                !_images.contains(img.toString())) {
              _images.add(img.toString());
            }
          }
        }

        // Extract colors and sizes from API (they are often lists)
        final rawColors = product!['color'] ?? product!['colors'];
        if (rawColors is List) {
          _colors = rawColors.map((e) => e.toString()).toList();
        }

        final rawSizes = product!['size'] ?? product!['sizes'];
        if (rawSizes is List) {
          _sizes = rawSizes.map((e) => e.toString()).toList();
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return _buildSkeleton();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Obx(() {
            final String? id =
                product?['id']?.toString() ?? product?['_id']?.toString();
            final bool isFav = wishlistController.isFavorite(id);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.black,
              ),
              onPressed: () => wishlistController.toggleFavorite(product),
            );
          }),
        ],
        backgroundColor: const Color.fromARGB(255, 227, 207, 54),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProductDetail(),
              const SizedBox(height: 24),
              buildQuantitySelector(),
              if (_colors.isNotEmpty) ...[
                const SizedBox(height: 24),
                buildProductColor(),
              ],
              if (_sizes.isNotEmpty) ...[
                const SizedBox(height: 24),
                buildProductSize(),
              ],
              const SizedBox(height: 24),
              buildProductDescription(),
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      bottomSheet: buildBottomAction(),
    );
  }

  // ================= PRODUCT IMAGE + INDICATOR =================
  Widget buildProductDetail() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[100],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length.clamp(1, 10),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final String imageUrl = _images.isNotEmpty
                    ? BaseUrl.getFullImageUrl(_images[index])
                    : "";

                final imageWidget = imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, size: 100),
                      )
                    : const Icon(Icons.image, size: 100);

                if (index == 0 && heroTag != null) {
                  return Center(
                    child: Hero(tag: heroTag!, child: imageWidget),
                  );
                }

                return Center(child: imageWidget);
              },
            ),
          ),
          if (_images.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color.fromARGB(255, 227, 207, 54)
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= QUANTITY SELECTOR =================
  Widget buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quantity",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: 130,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQtyButton(
                icon: Icons.remove,
                onTap: () {
                  if (_quantity > 1) {
                    setState(() => _quantity--);
                  }
                },
              ),
              Text(
                _quantity.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildQtyButton(
                icon: Icons.add,
                onTap: () {
                  setState(() => _quantity++);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  // ================= COLOR SELECTOR =================
  Widget buildProductColor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Color",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _colors.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedColorIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color.fromARGB(255, 227, 207, 54)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      _colors[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= SIZE SELECTOR =================
  Widget buildProductSize() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Size",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _sizes.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedSizeIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedSizeIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  width: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color.fromARGB(255, 227, 207, 54)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      _sizes[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= DESCRIPTION =================
  Widget buildProductDescription() {
    final String title =
        product!['title']?.toString() ??
        product!['name']?.toString() ??
        "Product Detail";
    final String price = product!['price']?.toString() ?? "0.00";
    final String description =
        product!['description']?.toString() ??
        "No description available for this product.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              "\$$price",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 227, 207, 54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(),
        const Text(
          "Description",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ExpandableText(text: description),
      ],
    );
  }

  // ================= BOTTOM ACTION BAR =================
  Widget buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: customButton(
                title: "Add to Cart",
                onTap: () {
                  final String priceStr = product!['price']?.toString() ?? "0";
                  final double price = double.tryParse(priceStr) ?? 0.0;
                  final String imageUrl = _images.isNotEmpty
                      ? _images[0]
                      : (product!['image']?.toString() ?? "");

                  Navigator.pushNamed(
                    context,
                    BaseRoute.checkout,
                    arguments: {
                      'title': product!['title'] ?? product!['name'],
                      'image': BaseUrl.getFullImageUrl(imageUrl),
                      'price': price,
                      'qty': _quantity,
                    },
                  );
                },
                color: const Color.fromARGB(255, 227, 207, 54),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: customButton(
                title: "Payment",
                onTap: () {
                  final String priceStr = product!['price']?.toString() ?? "0";
                  final double price = double.tryParse(priceStr) ?? 0.0;
                  final String colorStr = _colors.isNotEmpty
                      ? _colors[_selectedColorIndex]
                      : "";
                  Navigator.pushNamed(
                    context,
                    BaseRoute.payment,
                    arguments: {
                      'price': price,
                      'qty': _quantity,
                      'color': colorStr,
                    },
                  );
                },
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customButton({
    required String title,
    required Function onTap,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(0, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color == Colors.black ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 227, 207, 54),
        elevation: 0,
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(height: 20, width: 100, color: Colors.white),
                const SizedBox(height: 12),
                Container(
                  height: 40,
                  width: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(height: 20, width: 120, color: Colors.white),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 12),
                      height: 45,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(height: 20, width: 120, color: Colors.white),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    4,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 12),
                      height: 45,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 28, width: 200, color: Colors.white),
                    Container(height: 28, width: 80, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                Container(height: 20, width: 120, color: Colors.white),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(height: 16, width: 250, color: Colors.white),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        height: 100,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CUSTOM EXPANDABLE TEXT WIDGET =================
class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({super.key, required this.text});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, height: 1.5),
        ),
        GestureDetector(
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Text(
            isExpanded ? "See Less" : "See More",
            style: const TextStyle(
              color: Color.fromARGB(255, 227, 207, 54),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
