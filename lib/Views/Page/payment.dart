import 'package:demo_interview/Route/base_routes.dart';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final Color kMainColor = Colors.black;
  int _selectedPaymentIndex = 0;
  String _deliveryAddress = "123 Premium St, Modern City, 12345";
  double _price = 0.0;
  int _qty = 1;
  String _color = "";
  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _price = args['price'] ?? 0.0;
      _qty = args['qty'] ?? 1;
      _color = args['color']?.toString() ?? "";
    }
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "name": "ABA Payway",
      "icon": Icons.qr_code_scanner,
      "subtitle": "Pay securely with ABA",
    },
    {
      "name": "Cash on Delivery",
      "icon": Icons.money,
      "subtitle": "Pay at your doorstep",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
              color: kMainColor.withValues(alpha: 0.1),
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
              color: isSelected ? Colors.amber[200] : Colors.white,
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
    final double subtotal = _price * _qty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Price / Unit", "\$${_price.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          _buildSummaryRow("QTY", "$_qty"),
          const SizedBox(height: 8),
          if (_color.isNotEmpty) _buildSummaryRow("Color", _color),
          const SizedBox(height: 8),
          _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSummaryRow(
            "Total Amount",
            "\$${subtotal.toStringAsFixed(2)}",
            isTotal: true,
          ),
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
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isProcessing
              ? null
              : () async {
                  final selectedMethod =
                      _paymentMethods[_selectedPaymentIndex]['name'];
                  if (selectedMethod == "ABA Payway") {
                    await _handleAbaPayment();
                  } else {
                    _showSuccessDialog();
                  }
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
          child: _isProcessing
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Payment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Future<void> _handleAbaPayment() async {
    setState(() => _isProcessing = true);

    try {
      final String? token = await BaseUrl.getToken();
      final double totalAmount = _price * _qty;

      if (totalAmount <= 0) {
        throw 'Invalid total amount (\$totalAmount). Please check product price and quantity.';
      }

      // 🚀 Debug log full request
      debugPrint("🚀 Calling: ${BaseUrl.paywayCreatePaymentUrl}");
      debugPrint("📦 Payload: amount: $totalAmount");

      final response = await http
          .post(
            Uri.parse(BaseUrl.paywayCreatePaymentUrl),
            headers: {
              'Authorization': 'Bearer ${token ?? ""}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'amount': totalAmount,
              'firstName': 'User',
              'lastName': 'Demo',
            }),
          )
          .timeout(const Duration(seconds: 60));

      // 📥 Debug log response
      debugPrint("📥 Status: ${response.statusCode}");
      debugPrint("📄 Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];

        if (data == null) throw 'Server success but no data';

        final String hash = data['hash'] ?? "";
        final String transactionId = data['tran_id']?.toString() ?? "";
        final String amount = data['amount']?.toString() ?? "";
        final String reqTime = data['req_time']?.toString() ?? "";
        final String merchantId = data['merchant_id']?.toString() ?? "";
        final String returnUrl = data['return_url'] ?? "";
        final String continueSuccessUrl = data['continue_success_url'] ?? "";

        if (hash.isEmpty || transactionId.isEmpty)
          throw 'Missing payment params';

        final Map<String, String> redirectParams = {
          'req_time': reqTime,
          'tran_id': transactionId,
          'amount': amount,
          'hash': hash,
          'firstName': 'User',
          'lastName': 'Demo',
          'merchant_id': merchantId,
          'return_url': returnUrl,
          'continue_success_url': continueSuccessUrl,
        };

        if (data['items'] != null) {
          redirectParams['items'] = data['items'].toString();
        }

        final Uri checkoutUri = Uri.parse(
          BaseUrl.paywayRenderCheckoutUrl,
        ).replace(queryParameters: redirectParams);

        if (await canLaunchUrl(checkoutUri)) {
          await launchUrl(checkoutUri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch payment gateway. Please check your internet connection.';
        }
      } else {
        String msg = 'Payment error (${response.statusCode})';
        try {
          final error = jsonDecode(response.body);
          msg = error['message'] ?? msg;
        } catch (_) {}
        throw msg;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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
                color: Colors.green.withValues(alpha: 0.1),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
