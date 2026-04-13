// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:demo_interview/Views/Screen/favorite.dart';
import 'package:demo_interview/Views/Screen/home.dart';
import 'package:demo_interview/Views/Screen/store.dart';
import 'package:demo_interview/Views/Screen/menu.dart';
import 'package:demo_interview/Route/base_routes.dart';
import 'package:demo_interview/Controllers/wishlist_controller.dart';
import 'package:demo_interview/Controllers/cart_controller.dart';
import 'package:demo_interview/Controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final RxBool hasNotification = true.obs; // Example initial state

  final screens = [const Home(), const Favorite(), const Store(), const Menu()];

  void navigateToFavorite(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Favorite()),
    );
  }

  void navigateToStore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Store()),
    );
  }

  void navigateToMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Menu()),
    );
  }
}

class THelperFunctions {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: BaseRoute.loading,
      routes: BaseRoute.routes,
    );
  }
}

class MainScreen extends StatelessWidget {
  final NavigationController controller = Get.put(NavigationController());
  final WishlistController wishlistController = Get.put(WishlistController());
  final CartController cartController = Get.put(CartController());
  final ProfileController profileController = Get.put(ProfileController());

  MainScreen({super.key}) {
    _initData();
  }

  Future<void> _initData() async {
    // 1. Fetch Profile first (other controllers depend on user ID)
    await profileController.fetchProfile();
    
    // 2. Fetch Dependent Data
    await Future.wait([
      cartController.fetchCart(),
      wishlistController.fetchWishlist(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "E-SHOPPING",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 227, 207, 54),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, BaseRoute.addToCart);
                  },
                  icon: Image.asset(
                    "icons/add_card.png",
                    height: 30,
                    width: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 85,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) {
            controller.selectedIndex.value = index; // Update the selected index
          },
          backgroundColor: darkMode ? Colors.black : Colors.white,
          indicatorColor: darkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          destinations: [
            NavigationDestination(
              icon: Image.asset("icons/home.png", height: 25, width: 25),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded, size: 25),
              label: 'Favorite',
            ),
            NavigationDestination(
              icon: Image.asset(
                "icons/shopping-cart.png",
                height: 25,
                width: 25,
              ),
              label: 'Store',
            ),
            NavigationDestination(
              icon: Image.asset("icons/menu.png", height: 25, width: 25),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}
