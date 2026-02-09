import 'package:flutter/material.dart';
import 'package:demo_interview/Route/base_routes.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // 'order', 'promo', 'system'
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'Order Delivered',
      description:
          'Your order #12345 has been delivered successfully. Enjoy your purchase!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: 'order',
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Big Sale Alert!',
      description:
          'Get up to 50% off on all summer collections. Shop now before it\'s gone!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'promo',
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'System Update',
      description:
          'We have updated our terms of service. Please review them at your convenience.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: 'system',
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'New Arrival',
      description:
          'Check out the new Nike Air Max collection just added to our store.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: 'promo',
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      title: 'Order Confirmed',
      description:
          'Your order #12346 has been confirmed and is being prepared.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: 'order',
      isRead: false,
    ),
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Orders', 'Promotions', 'System'];

  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    return _notifications.where((n) {
      if (_selectedFilter == 'Orders' && n.type == 'order') return true;
      if (_selectedFilter == 'Promotions' && n.type == 'promo') return true;
      if (_selectedFilter == 'System' && n.type == 'system') return true;
      return false;
    }).toList();
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Read All',
              style: TextStyle(
                color: Color.fromARGB(255, 227, 207, 54),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _buildNotificationTile(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(filter),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: const Color.fromARGB(255, 227, 207, 54),
              backgroundColor: Colors.grey[200],
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          setState(() {
            notification.isRead = true;
          });
          Navigator.pushNamed(
            context,
            BaseRoute.notificationDetail,
            arguments: notification,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.transparent : Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getIconColor(notification.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(notification.type),
                  color: _getIconColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          _getTimeAgo(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 227, 207, 54),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Notifications Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We will notify you when something important \nhappens.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
