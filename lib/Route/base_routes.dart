import 'package:demo_interview/Lang/language.dart';
import 'package:demo_interview/Views/Page/address.dart';
import 'package:demo_interview/Views/Page/addtocart.dart';
import 'package:demo_interview/Views/Page/payment.dart';
import 'package:demo_interview/Views/Screen/menu.dart';
import 'package:demo_interview/Views/Page/order_history.dart';
import 'package:demo_interview/Views/Page/wishlist.dart';
import 'package:demo_interview/Views/Page/changepass.dart';
import 'package:demo_interview/Views/Page/managepayment.dart';
import 'package:demo_interview/Views/Page/helpcenter.dart';
import 'package:demo_interview/Views/Page/privacypolicy.dart';
import 'package:demo_interview/Views/Page/termsofservice.dart';
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
import 'package:demo_interview/Views/Page/filter_product.dart';
import 'package:demo_interview/Views/Page/signuploadprofile.dart';
import 'package:demo_interview/Route/route_constants.dart';

class BaseRoute {
  static const String home = RouteConstants.home;
  static const String signin = RouteConstants.signin;
  static const String signup = RouteConstants.signup;
  static const String loading = RouteConstants.loading;
  static const String profile = RouteConstants.profile;
  static const String editProfile = RouteConstants.editProfile;
  static const String termsConditions = RouteConstants.termsConditions;
  static const String store = RouteConstants.store;
  static const String favorite = RouteConstants.favorite;
  static const String checkout = RouteConstants.checkout;
  static const String menu = RouteConstants.menu;
  static const String buy = RouteConstants.buy;
  static const String dashboard = RouteConstants.dashboard;
  static const String productDetail = RouteConstants.productDetail;
  static const String address = RouteConstants.address;
  static const String orderHistory = RouteConstants.orderHistory;
  static const String wishlist = RouteConstants.wishlist;
  static const String changepass = RouteConstants.changepass;
  static const String language = RouteConstants.language;
  static const String filterProduct = RouteConstants.filterProduct;
  static const String addToCart = RouteConstants.addToCart;
  static const String payment = RouteConstants.payment;
  static const String notification = RouteConstants.notification;
  static const String notificationDetail = RouteConstants.notificationDetail;
  static const String managePayment = RouteConstants.managePayment;
  static const String helpCenter = RouteConstants.helpCenter;
  static const String privacyPolicy = RouteConstants.privacyPolicy;
  static const String termsOfService = RouteConstants.termsOfService;
  static const String signUploadProfile = RouteConstants.signUploadProfile;

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
    wishlist: (context) => const WishlistScreen(),
    changepass: (context) => const ChangePasswordScreen(),
    language: (context) => const LanguageScreen(),
    filterProduct: (context) => const FilterProduct(),
    addToCart: (context) => const AddToCart(),
    payment: (context) => const Payment(),
    managePayment: (context) => const ManagePayment(),
    helpCenter: (context) => const HelpCenter(),
    privacyPolicy: (context) => const PrivacyPolicy(),
    termsOfService: (context) => const TermsOfService(),
    signUploadProfile: (context) => SignUploadProfile(
      userData:
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?,
    ),
  };
}
