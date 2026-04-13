import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Controllers/cart_controller.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  final CartController cartController = Get.find();

  double get subtotal {
    double sum = 0;
    for (var item in cartController.cartItems) {
      final product = item['product'] ?? item;
      final priceStr =
          product['price']?.toString() ??
          product['base_price']?.toString() ??
          "0";
      final double price = double.tryParse(priceStr) ?? 0.0;
      final int qty =
          int.tryParse(
            item['qty']?.toString() ?? item['quantity']?.toString() ?? "1",
          ) ??
          1;
      sum += (price * qty);
    }
    return sum;
  }

  void _incrementQuantity(int index) {
    final item = cartController.cartItems[index];
    final String? cartId = item['id']?.toString() ?? item['_id']?.toString();
    if (cartId != null) {
      final int currentQty =
          int.tryParse(
            item['qty']?.toString() ?? item['quantity']?.toString() ?? "1",
          ) ??
          1;
      cartController.updateQuantity(cartId, currentQty + 1);
    }
  }

  void _decrementQuantity(int index) {
    final item = cartController.cartItems[index];
    final String? cartId = item['id']?.toString() ?? item['_id']?.toString();
    if (cartId != null) {
      final int currentQty =
          int.tryParse(
            item['qty']?.toString() ?? item['quantity']?.toString() ?? "1",
          ) ??
          1;
      if (currentQty > 1) {
        cartController.updateQuantity(cartId, currentQty - 1);
      }
    }
  }

  void _removeItem(dynamic item) {
    final String? cartId = item['id']?.toString() ?? item['_id']?.toString();
    if (cartId != null) {
      cartController.removeFromCart(cartId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Obx(() {
        if (cartController.isLoading.value &&
            cartController.cartItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 100,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 20),
                Text(
                  "Your cart is empty",
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                Text(
                  "Add some items to start shopping!",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => cartController.fetchCart(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartController.cartItems[index];
                    final String id =
                        item['id']?.toString() ??
                        item['_id']?.toString() ??
                        index.toString();
                    return Dismissible(
                      key: ValueKey(id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeItem(item),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                      child: _buildCartItem(item, index),
                    );
                  },
                ),
              ),
            ),
            _buildCheckoutSection(),
          ],
        );
      }),
    );
  }

  Widget _buildCartItem(dynamic item, int index) {
    final product = item['product'] ?? {};
    final String title =
        product['title']?.toString() ??
        product['name']?.toString() ??
        "Product";
    final String priceStr =
        product['price']?.toString() ??
        product['base_price']?.toString() ??
        "0";
    final double price = double.tryParse(priceStr) ?? 0.0;
    final int quantity =
        int.tryParse(
          item['qty']?.toString() ?? item['quantity']?.toString() ?? "1",
        ) ??
        1;
    final String imageUrl = BaseUrl.getFullImageUrl(
      product['image']?.toString() ?? product['image_url']?.toString(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    _buildQuantityControls(index, quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(int index, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          _iconButton(
            icon: Icons.remove,
            onTap: () => _decrementQuantity(index),
            isActive: quantity > 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          _iconButton(
            icon: Icons.add,
            onTap: () => _incrementQuantity(index),
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: isActive ? Colors.black : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        100,
      ), // Extra bottom padding for TabBar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${subtotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (cartController.cartItems.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    BaseRoute.payment,
                    arguments: {
                      'title':
                          "Cart Items (${cartController.cartItems.length})",
                      'price': subtotal,
                      'qty': 1,
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Proceed to Checkout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
