import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';
import 'navigation/app_transitions.dart';
import 'controllers/app_controller.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/messages/messages_screen.dart';
import 'screens/orders/order_checkout_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/orders/order_details_screen.dart';
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
import 'screens/profile/profile_setup_screen.dart';
import 'screens/profile/public_profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';

import 'screens/notifications/notifications_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/help/help_screen.dart';
import 'screens/settings/privacy_screen.dart';
import 'screens/product/trending_explorer_screen.dart';
import 'screens/product/nearby_explorer_screen.dart';
import 'screens/explorer/trending_shops_screen.dart';
import 'screens/explorer/nearby_shops_screen.dart';
import 'screens/seller/individual_dashboard_screen.dart';

// API
import 'Api/core/api_client.dart';
import 'Api/services/auth_service.dart';
import 'Api/services/boutique_service.dart';
import 'Api/services/produit_service.dart';
import 'Api/services/category_service.dart';
import 'Api/services/favori_service.dart';
import 'Api/services/user_service.dart';
import 'Api/services/report_service.dart';
import 'Api/provider/auth_controller.dart';
import 'controllers/boutique_controller.dart';
import 'controllers/my_products_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/search_history_controller.dart';
import 'controllers/notification_controller.dart';

import 'Api/firebase/services/chat_service.dart';
import 'Api/firebase/controllers/chat_controller.dart';
import 'Api/firebase/services/fcm_service.dart';
import 'Api/firebase/services/firebase_auth_bridge_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // await FlutterSecureStorage().deleteAll(); // DEBUG ONLY — à ne pas décommenter en production

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Auth Dependencies
  final apiClient = ApiClient();
  Get.put(apiClient, permanent: true);

  final authService = AuthService(apiClient);
  final boutiqueService = BoutiqueService(apiClient);
  final produitService = ProduitService(apiClient);
  final categoryService = CategoryService(apiClient);
  final userService = UserService(apiClient);

  Get.put(authService, permanent: true);
  Get.put(boutiqueService, permanent: true);
  Get.put(produitService, permanent: true);
  Get.put(categoryService, permanent: true);
  Get.put(userService, permanent: true);
  Get.put(FavoriService(apiClient), permanent: true);
  Get.put(ReportService(apiClient), permanent: true);

  Get.put(FirebaseAuthBridgeService(apiClient), permanent: true);
  Get.put(AuthController(authService), permanent: true);
  Get.put(BoutiqueController(boutiqueService), permanent: true);

  // Initialize global controllers
  Get.put(AppController());
  Get.put(ChatService(), permanent: true);
  Get.putAsync(() => FCMService().init(), permanent: true);
  Get.put(ChatController());
  Get.put(DashboardController());
  Get.put(MyProductsController());
  Get.put(OrderController());
  Get.put(SearchHistoryController(), permanent: true);
  Get.put(NotificationController(), permanent: true);

  runApp(const TogoMarketApp());
}

class TogoMarketApp extends StatelessWidget {
  const TogoMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: 'Togo Market',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/splash',
        transitionDuration: const Duration(milliseconds: 300),
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child!,
          );
        },
        getPages: [
          togoPage('/splash', () => const SplashScreen(),
              style: TogoRouteStyle.softFade),
          togoPage('/onboarding', () => const OnboardingScreen(),
              style: TogoRouteStyle.softFade),
          togoPage('/auth', () => const AuthScreen(),
              style: TogoRouteStyle.softFade),
          togoPage('/home', () => const HomeScreen()),
          GetPage(name: '/category', page: () => const CategoryScreen()),
          togoPage('/search', () => const SearchScreen()),
          togoPage('/product/:id', () => const ProductDetailScreen()),
          togoPage('/chat/:id', () => const ChatScreen()),
          togoPage('/messages', () => const MessagesScreen()),
          togoPage('/order', () => const OrderCheckoutScreen()),
          togoPage('/seller/:id', () => SellerScreen()),
          togoPage('/dashboard', () => const DashboardScreen()),
          togoPage('/add-product', () => const AddProductScreen(),
              style: TogoRouteStyle.modalLift),
          togoPage('/shop-information', () => const ShopInformationScreen()),
          togoPage(
            '/edit-shop',
            () => const EditShopScreen(),
            style: TogoRouteStyle.modalLift,
          ),
          GetPage(
            name: '/store-settings',
            page: () => const StoreConfigurationScreen(),
          ),
          togoPage(
            '/edit-product/:id',
            () => const EditProductScreen(),
            style: TogoRouteStyle.modalLift,
          ),
          togoPage('/seller-stats', () => const SellerStatsScreen()),
          togoPage('/coverage-zones', () => const CoverageZonesScreen()),
          togoPage('/opening-hours', () => const OpeningHoursScreen()),
          togoPage(
              '/product-categories', () => const ProductCategoriesScreen()),
          togoPage('/return-policy', () => const ReturnPolicyScreen()),
          togoPage(
              '/seller-help-center', () => const SellerHelpCenterScreen()),
          togoPage('/notifications', () => const NotificationsScreen()),
          togoPage('/profile', () => const ProfileScreen()),
          GetPage(
              name: '/profile-setup',
              page: () => const ProfileSetupScreen()),
          togoPage('/profile/:id', () => const PublicProfileScreen()),
          togoPage('/edit-profile', () => const EditProfileScreen(),
              style: TogoRouteStyle.modalLift),

          togoPage('/shop-settings', () => const ShopSettingsScreen()),
          togoPage('/settings', () => const SettingsScreen()),
          togoPage('/privacy', () => const PrivacyScreen()),
          togoPage('/favorites', () => const FavoritesScreen()),
          togoPage('/orders', () => const OrdersScreen()),
          togoPage('/order-details', () => const OrderDetailsScreen()),
          togoPage('/help', () => const HelpScreen()),
          togoPage('/trends', () => const TrendingExplorerScreen()),
          togoPage('/nearby', () => const NearbyExplorerScreen()),
          togoPage('/trending-shops', () => const TrendingShopsScreen()),
          togoPage('/nearby-shops', () => const NearbyShopsScreen()),
          togoPage('/individual-dashboard',
              () => const IndividualDashboardScreen()),
        ],
      ),
    );
  }
}
