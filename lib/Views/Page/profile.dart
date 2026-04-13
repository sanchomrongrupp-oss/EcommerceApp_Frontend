import 'dart:io';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Controllers/profile_controller.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.find();
  final Color kMainColor = const Color.fromARGB(255, 227, 207, 54);

  @override
  void initState() {
    super.initState();
    profileController.fetchProfile();
  }

  Future<void> _pickImage() async {
    final image = await profileController.uploadImageFromGallery();
    if (image != null) {
      Get.snackbar("Success", "Profile image updated!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Obx(
        () => CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const _SectionHeader(title: "Account Settings"),
                    _buildSettingItem(
                      Icons.person_outline,
                      "Edit Profile",
                      "Change your profile details",
                      () async {
                        final result = await Navigator.pushNamed(
                          context,
                          BaseRoute.editProfile,
                        );
                        if (result == true) {
                          profileController.fetchProfile();
                        }
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
                        Navigator.pushNamed(context, BaseRoute.managePayment);
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionHeader(title: "Support & Privacy"),
                    _buildSettingItem(
                      Icons.help_outline,
                      "Help Center",
                      "Get help and contact support",
                      () {
                        Navigator.pushNamed(context, BaseRoute.helpCenter);
                      },
                    ),
                    _buildSettingItem(
                      Icons.privacy_tip_outlined,
                      "Privacy Policy",
                      "Read our privacy guidelines",
                      () {
                        Navigator.pushNamed(context, BaseRoute.privacyPolicy);
                      },
                    ),
                    _buildSettingItem(
                      Icons.description_outlined,
                      "Terms of Service",
                      "Our rules and regulations",
                      () {
                        Navigator.pushNamed(context, BaseRoute.termsOfService);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                        child: profileController.isLoading.value
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: const CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    profileController.imageUrl.value.isNotEmpty
                                    ? NetworkImage(
                                        profileController.imageUrl.value,
                                      )
                                    : const AssetImage('icons/user.png')
                                          as ImageProvider,
                                child: profileController.imageUrl.value.isEmpty
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
                          onTap: () async {
                            await profileController.uploadImageFromGallery();
                          },
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
                  if (profileController.isLoading.value)
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        children: [
                          Container(
                            height: 22,
                            width: 150,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 14,
                            width: 100,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          profileController.userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "ID: ${profileController.userId.value}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
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
            color: kMainColor.withOpacity(0.1),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
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
}
