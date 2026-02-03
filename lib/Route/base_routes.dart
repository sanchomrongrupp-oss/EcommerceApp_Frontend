import 'package:demo_interview/Views/Page/menu.dart';
import 'package:demo_interview/Views/Product_detail/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:demo_interview/main.dart'; // Import for MainScreen
import 'package:demo_interview/Views/Screen/home.dart';
import 'package:demo_interview/Views/Page/signin.dart';
import 'package:demo_interview/Views/Page/singup.dart';
import 'package:demo_interview/Views/Page/loading.dart';
import 'package:demo_interview/Views/Screen/store.dart';
import 'package:demo_interview/Views/Screen/favorite.dart';
import 'package:demo_interview/Views/Page/card.dart'; // CheckOut
import 'package:demo_interview/Views/Page/buy.dart'; // Buyproduct
import 'package:demo_interview/Views/Screen/profile.dart'; // profile_screen

class BaseRoute {
  static const String home = '/home';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String loading = '/loading';
  static const String profile = '/profile';
  static const String store = '/store';
  static const String favorite = '/favorite';
  static const String checkout = '/checkout';
  static const String menu = '/menu';
  static const String buy = '/buy';
  static const String dashboard = '/dash_board';
  static const String productDetail = '/product_detail';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const Home(),
    signin: (context) => const Signin(),
    signup: (context) => const Singup(),
    loading: (context) => const Loading(),
    profile: (context) => const ProfileScreen(),
    store: (context) => const Store(),
    favorite: (context) => const Favorite(),
    checkout: (context) => CheckOut(),
    menu: (context) => const Menu(),
    buy: (context) => const Buyproduct(),
    dashboard: (context) => MainScreen(),
    productDetail: (context) => const ProductDetail(),
  };
}
