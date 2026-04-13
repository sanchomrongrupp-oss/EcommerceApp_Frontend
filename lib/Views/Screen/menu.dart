import 'package:demo_interview/Controllers/profile_controller.dart';
import 'package:demo_interview/Controllers/cart_controller.dart';
import 'package:demo_interview/Controllers/wishlist_controller.dart';
import 'package:demo_interview/Base_Url/base_url.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:demo_interview/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    profileController.fetchProfile();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final NavigationController navigationController = Get.find();
                navigationController.selectedIndex.value = 0;

                // Clear authentication token
                await BaseUrl.removeToken();

                // Delete GetX controllers to reset state
                Get.delete<ProfileController>(force: true);
                Get.delete<CartController>(force: true);
                Get.delete<WishlistController>(force: true);

                if (mounted) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(BaseRoute.signin, (route) => false);
                }
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              _ProfileCard(
                name: profileController.userName,
                userId: profileController.userId.value,
                imagePath: profileController.imageUrl.value,
                backgroundColor: Colors.black,
                isLoading: profileController.isLoading.value,
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.profile);
                },
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: "Account Information"),
              _MenuTile(
                icon: Icons.location_pin,
                title: "Address",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.address);
                },
              ),
              _MenuTile(
                icon: Icons.shopping_bag_outlined,
                title: "Order History",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.orderHistory);
                },
              ),
              _MenuTile(
                icon: Icons.favorite_border_rounded,
                title: "Wishlist",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.wishlist);
                },
              ),
              const SizedBox(height: 20),
              const _SectionHeader(title: "Payments"),
              _MenuTile(
                icon: Icons.add_card,
                title: "Manage Payment",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.managePayment);
                },
              ),
              const SizedBox(height: 20),
              const _SectionHeader(title: "Settings & Help"),
              _MenuTile(
                icon: Icons.contact_support_outlined,
                title: "Help Center",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.helpCenter);
                },
              ),
              _MenuTile(
                icon: Icons.key_outlined,
                title: "Change Password",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.changepass);
                },
              ),
              _MenuTile(
                icon: Icons.language,
                title: "Language",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.language);
                },
              ),
              _MenuTile(
                icon: Icons.notifications_none_rounded,
                title: "Notifications",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.notification);
                },
              ),
              _MenuTile(
                icon: Icons.contact_support_outlined,
                title: "Privacy Policy",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.privacyPolicy);
                },
              ),
              _MenuTile(
                icon: Icons.contact_support_outlined,
                title: "Terms of Service",
                onTap: () {
                  Navigator.pushNamed(context, BaseRoute.termsOfService);
                },
              ),
              _MenuTile(
                icon: Icons.logout_rounded,
                title: "Logout",
                isDestructive: true,
                onTap: () => _showLogoutDialog(context),
              ),
              const SizedBox(height: 30),
              const _FooterInfo(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String userId;
  final String imagePath;
  final Color backgroundColor;
  final bool isLoading;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.name,
    required this.userId,
    required this.imagePath,
    required this.backgroundColor,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
            child: Row(
              children: [
                isLoading
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          backgroundImage: imagePath.isNotEmpty
                              ? NetworkImage(imagePath)
                              : const AssetImage('icons/user.png')
                                    as ImageProvider,
                          radius: 50,
                          backgroundColor: Colors.white,
                        ),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Member ID : $userId",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    const kMainColor = Color.fromARGB(255, 227, 207, 54);
    final color = isDestructive ? Colors.redAccent : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : kMainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isDestructive ? Colors.redAccent : Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: isDestructive ? Colors.red : Colors.grey[600],
                ),
              ],
            ),
          ),
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
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterInfo extends StatelessWidget {
  const _FooterInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          "SHOPING",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black38,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Version 1.0.1",
          style: TextStyle(fontSize: 12, color: Colors.black26),
        ),
      ],
    );
  }
}
