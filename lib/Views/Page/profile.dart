import 'dart:io';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final Color kMainColor = const Color.fromARGB(255, 227, 207, 54);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderBoard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Account Settings"),
                  _buildSettingItem(
                    Icons.person_outline,
                    "Edit Profile",
                    "Change your profile details",
                    () {
                      Navigator.pushNamed(context, BaseRoute.editProfile);
                    },
                  ),
                  _buildSettingItem(
                    Icons.location_on_outlined,
                    "Shipping Address",
                    "Manage your delivery addresses",
                    () {
                      Navigator.pushNamed(context, BaseRoute.address);
                    },
                  ),
                  _buildSettingItem(
                    Icons.payment_outlined,
                    "Payment Methods",
                    "Update your card information",
                    () {
                      setState(() {
                        Navigator.pushNamed(context, BaseRoute.managePayment);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Support & Privacy"),
                  _buildSettingItem(
                    Icons.help_outline,
                    "Help Center",
                    "Get help and contact support",
                    () {
                      setState(() {
                        Navigator.pushNamed(context, BaseRoute.helpCenter);
                      });
                    },
                  ),
                  _buildSettingItem(
                    Icons.privacy_tip_outlined,
                    "Privacy Policy",
                    "Read our privacy guidelines",
                    () {
                      setState(() {
                        Navigator.pushNamed(context, BaseRoute.privacyPolicy);
                      });
                    },
                  ),
                  _buildSettingItem(
                    Icons.description_outlined,
                    "Terms of Service",
                    "Our rules and regulations",
                    () {
                      setState(() {
                        Navigator.pushNamed(context, BaseRoute.termsOfService);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: kMainColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            Container(decoration: BoxDecoration(color: kMainColor)),
            Positioned(
              bottom: 40,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : null,
                          child: _image == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[500],
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "User Name",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    "ID: 12345678",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Image.asset("icons/back.png"),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
    );
  }

  Widget _buildOrderBoard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, BaseRoute.orderHistory);
                },
                child: const Text(
                  "View All",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatusItem(Icons.payment, "Pending"),
              _buildOrderStatusItem(Icons.local_shipping, "Shipping"),
              _buildOrderStatusItem(Icons.inventory_2, "Received"),
              _buildOrderStatusItem(Icons.star_outline, "Review"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black87),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kMainColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black26,
        ),
      ),
    );
  }
}
