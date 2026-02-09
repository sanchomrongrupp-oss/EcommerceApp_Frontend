import 'package:demo_interview/Route/base_routes.dart';
import 'package:flutter/material.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final Color kMainColor = Colors.black;
  int _selectedPaymentIndex = 0;
  String _deliveryAddress = "123 Premium St, Modern City, 12345";

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "name": "Credit Card",
      "icon": Icons.credit_card,
      "subtitle": "**** **** **** 4242",
    },
    {
      "name": "PayPal",
      "icon": Icons.account_balance_wallet,
      "subtitle": "paypal@example.com",
    },
    {"name": "Apple Pay", "icon": Icons.apple, "subtitle": "Connected"},
    {
      "name": "Cash on Delivery",
      "icon": Icons.money,
      "subtitle": "Pay at your doorstep",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 227, 207, 54),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 227, 207, 54),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset("icons/back.png", height: 30, width: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Delivery Address"),
            const SizedBox(height: 12),
            _buildDeliveryCard(),
            const SizedBox(height: 32),

            _buildSectionTitle("Payment Method"),
            const SizedBox(height: 12),
            _buildPaymentMethods(),
            const SizedBox(height: 32),

            _buildSectionTitle("Order Summary"),
            const SizedBox(height: 12),
            _buildOrderSummary(),
            const SizedBox(height: 32),

            _buildPromoCode(),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kMainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on, color: kMainColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Home Address",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _deliveryAddress,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                BaseRoute.address,
              );
              if (result != null && result is String) {
                setState(() {
                  _deliveryAddress = result;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: List.generate(_paymentMethods.length, (index) {
        final method = _paymentMethods[index];
        final isSelected = _selectedPaymentIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedPaymentIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey[300] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.grey[300]! : Colors.grey[200]!,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  method['icon'],
                  color: isSelected ? Colors.black : Colors.grey[600],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.black87,
                        ),
                      ),
                      Text(
                        method['subtitle'],
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.black),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Subtotal", "\$299.00"),
          const SizedBox(height: 8),
          _buildSummaryRow("Shipping", "\$10.00"),
          const SizedBox(height: 8),
          _buildSummaryRow("Tax (5%)", "\$15.45"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSummaryRow("Total Amount", "\$324.45", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey[600],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.black,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter Promo Code",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Apply",
              style: TextStyle(color: kMainColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 227, 207, 54),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // Success BottomSheet or Navigation
            _showSuccessDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            "Payment",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        height: MediaQuery.of(context).size.height * 0.45,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Order Placed!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Your order has been placed successfully.\nWe will notify you once it's shipped.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kMainColor,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Back to Home",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
