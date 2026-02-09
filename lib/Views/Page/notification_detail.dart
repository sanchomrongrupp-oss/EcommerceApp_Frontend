import 'package:flutter/material.dart';
import 'package:demo_interview/Views/Page/notification.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  String _getTimeStr(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'promo':
        return Colors.orange;
      case 'system':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kMainColor = const Color.fromARGB(255, 227, 207, 54);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: _getIconColor(notification.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(notification.type),
                  color: _getIconColor(notification.type),
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getIconColor(
                            notification.type,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notification.type.toUpperCase(),
                          style: TextStyle(
                            color: _getIconColor(notification.type),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        _getTimeStr(notification.timestamp),
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notification.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildActionButtons(context, kMainColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color mainColor) {
    if (notification.type == 'order') {
      return Column(
        children: [
          _buildButton(
            label: "Track My Order",
            onPressed: () {
              // Action for tracking order
            },
            color: mainColor,
            textColor: Colors.white,
          ),
          const SizedBox(height: 12),
          _buildButton(
            label: "View Invoice",
            onPressed: () {
              // Action for invoice
            },
            color: Colors.white,
            textColor: Colors.black,
            border: BorderSide(color: Colors.grey[300]!),
          ),
        ],
      );
    } else if (notification.type == 'promo') {
      return Column(
        children: [
          _buildButton(
            label: "Shop Now",
            onPressed: () {
              // Action for shopping
            },
            color: mainColor,
            textColor: Colors.white,
          ),
          const SizedBox(height: 12),
          _buildButton(
            label: "Copy Coupon Code",
            onPressed: () {
              // Action for copying coupon
            },
            color: Colors.white,
            textColor: Colors.black,
            border: BorderSide(color: Colors.grey[300]!),
          ),
        ],
      );
    } else {
      return _buildButton(
        label: "I Understand",
        onPressed: () => Navigator.pop(context),
        color: mainColor,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
    BorderSide border = BorderSide.none,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: border,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
