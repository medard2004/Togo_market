import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'theme/app_theme.dart';
import 'controllers/app_controller.dart';
import 'navigation/app_transitions.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/orders/order_checkout_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/seller/seller_screen.dart';
import 'screens/seller/dashboard_screen.dart';
import 'screens/seller/shop_settings_screen.dart';
import 'screens/seller/shop_information_screen.dart';
import 'screens/seller/edit_shop_screen.dart';
import 'screens/seller/store_configuration_screen.dart';
import 'screens/seller/add_product_screen.dart';
import 'screens/seller/edit_product_screen.dart';
import 'screens/seller/seller_stats_screen.dart';
import 'screens/seller/coverage_zones_screen.dart';
import 'screens/seller/opening_hours_screen.dart';
import 'screens/seller/product_categories_screen.dart';
import 'screens/seller/return_policy_screen.dart';
import 'screens/seller/seller_help_center_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/help/help_screen.dart';
import 'screens/product/trending_explorer_screen.dart';
import 'screens/product/nearby_explorer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize global controllers
  Get.put(AppController());
  Get.put(ChatController());

  runApp(const TogoMarketApp());
}

class TogoMarketApp extends StatelessWidget {
  const TogoMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Togo Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/splash',
      transitionDuration: const Duration(milliseconds: 300),
      getPages: [
        togoPage('/splash', () => const SplashScreen(),
            style: TogoRouteStyle.softFade),
        togoPage('/onboarding', () => const OnboardingScreen(),
            style: TogoRouteStyle.softFade),
        togoPage('/auth', () => const AuthScreen(),
            style: TogoRouteStyle.softFade),
        togoPage('/home', () => const HomeScreen()),
        togoPage('/search', () => const SearchScreen()),
        togoPage('/product/:id', () => const ProductDetailScreen()),
        togoPage('/chat/:id', () => const ChatScreen()),
        togoPage('/messages', () => const MessagesScreen()),
        togoPage('/order', () => const OrderCheckoutScreen()),
        togoPage('/seller/:id', () => const SellerScreen()),
        togoPage('/dashboard', () => const DashboardScreen()),
        togoPage('/shop-settings', () => const ShopSettingsScreen()),
        togoPage('/shop-information', () => const ShopInformationScreen()),
        togoPage(
            '/edit-shop',
            () => EditShopScreen(
                  shop: Get.arguments as ShopInfo? ?? ShopInfo.sample,
                ),
            style: TogoRouteStyle.modalLift),
        togoPage('/store-config', () => const StoreConfigurationScreen()),
        togoPage('/add-product', () => const AddProductScreen(),
            style: TogoRouteStyle.modalLift),
        togoPage('/edit-product/:id', () => const EditProductScreen(),
            style: TogoRouteStyle.modalLift),
        togoPage('/seller-stats', () => const SellerStatsScreen()),
        togoPage('/coverage-zones', () => const CoverageZonesScreen()),
        togoPage('/opening-hours', () => const OpeningHoursScreen()),
        togoPage('/product-categories', () => const ProductCategoriesScreen()),
        togoPage('/return-policy', () => const ReturnPolicyScreen()),
        togoPage('/seller-help-center', () => const SellerHelpCenterScreen()),
        togoPage('/notifications', () => const NotificationsScreen()),
        togoPage('/profile', () => const ProfileScreen()),
        togoPage('/edit-profile', () => const EditProfileScreen(),
            style: TogoRouteStyle.modalLift),
        togoPage('/settings', () => const SettingsScreen()),
        togoPage('/favorites', () => const FavoritesScreen()),
        togoPage('/orders', () => const OrdersScreen()),
        togoPage('/help', () => const HelpScreen()),
        togoPage('/trends', () => const TrendingExplorerScreen()),
        togoPage('/nearby', () => const NearbyExplorerScreen()),
      ],
    );
  }
}
