import 'package:demo_interview/Lang/language.dart';
import 'package:demo_interview/Views/Page/address.dart';
import 'package:demo_interview/Views/Page/addtocard.dart';
import 'package:demo_interview/Views/Page/payment.dart';
import 'package:demo_interview/Views/Screen/menu.dart';
import 'package:demo_interview/Views/Page/oderhistory.dart';
import 'package:demo_interview/Views/Page/returning.dart';
import 'package:demo_interview/Views/Page/wishlist.dart';
import 'package:demo_interview/Views/Page/changepass.dart';
import 'package:demo_interview/Views/Page/notification.dart';
import 'package:demo_interview/Views/Page/notification_detail.dart';
import 'package:demo_interview/Views/Page/managepayment.dart';
import 'package:demo_interview/Views/Product_detail/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:demo_interview/main.dart'; // Import for MainScreen
import 'package:demo_interview/Views/Screen/home.dart';
import 'package:demo_interview/Views/Page/signin.dart';
import 'package:demo_interview/Views/Page/signup.dart';
import 'package:demo_interview/Views/Page/loading.dart';
import 'package:demo_interview/Views/Screen/store.dart';
import 'package:demo_interview/Views/Screen/favorite.dart';
import 'package:demo_interview/Views/Page/card.dart'; // CheckOut
import 'package:demo_interview/Views/Page/buy.dart'; // Buyproduct
import 'package:demo_interview/Views/Page/profile.dart'; // profile_screen
import 'package:demo_interview/Views/Page/editprofile.dart'; // editprofile_screen
import 'package:demo_interview/Views/Page/termsconditions.dart'; // termsconditions_screen
import 'package:demo_interview/Views/Page/filtterproduct.dart';

class BaseRoute {
  static const String home = '/home';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String loading = '/loading';
  static const String profile = '/profile';
  static const String editProfile = '/editprofile';
  static const String termsConditions = '/termsconditions';
  static const String store = '/store';
  static const String favorite = '/favorite';
  static const String checkout = '/checkout';
  static const String menu = '/menu';
  static const String buy = '/buy';
  static const String dashboard = '/dash_board';
  static const String productDetail = '/product_detail';
  static const String address = '/address';
  static const String orderHistory = '/order_history';
  static const String returning = '/returning';
  static const String wishlist = '/wishlist';
  static const String changepass = '/changepass';
  static const String language = '/language';
  static const String filterProduct = '/filter_product';
  static const String addToCard = '/add_to_card';
  static const String payment = '/payment';
  static const String notification = '/notification';
  static const String notificationDetail = '/notificationDetail';
  static const String managePayment = '/managePayment';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const Home(),
    signin: (context) => const Signin(),
    signup: (context) => const Signup(),
    loading: (context) => const Loading(),
    profile: (context) => const ProfileScreen(),
    editProfile: (context) => const EditProfileScreen(),
    termsConditions: (context) => const TermsConditionsScreen(),
    store: (context) => const Store(),
    favorite: (context) => const Favorite(),
    checkout: (context) => CheckOut(),
    menu: (context) => const Menu(),
    buy: (context) => const Buyproduct(),
    dashboard: (context) => MainScreen(),
    productDetail: (context) => const ProductDetail(),
    address: (context) => const AddressScreen(),
    orderHistory: (context) => const OrderHistoryScreen(),
    returning: (context) => const ReturningScreen(),
    wishlist: (context) => const WishlistScreen(),
    changepass: (context) => const ChangePasswordScreen(),
    language: (context) => const LanguageScreen(),
    filterProduct: (context) => const FilterProduct(),
    addToCard: (context) => const AddToCard(),
    payment: (context) => const Payment(),
    notification: (context) => const NotificationScreen(),
    notificationDetail: (context) {
      final notification =
          ModalRoute.of(context)!.settings.arguments as NotificationModel;
      return NotificationDetailScreen(notification: notification);
    },
    managePayment: (context) => const ManagePayment(),
  };
}
