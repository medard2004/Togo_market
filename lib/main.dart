import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // utilisé uniquement par la ligne DEBUG commentée
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

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
import 'screens/seller/seller_screen.dart';
import 'screens/seller/dashboard_screen.dart';
import 'screens/seller/shop_settings_screen.dart';
import 'screens/seller/shop_information_screen.dart';
import 'screens/seller/edit_shop_screen.dart';
import 'screens/seller/store_configuration_screen.dart';
import 'screens/seller/add_product_screen.dart';
import 'screens/seller/edit_product_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_setup_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/help/help_screen.dart';

// API
import 'Api/core/api_client.dart';
import 'Api/services/auth_service.dart';
import 'Api/services/boutique_service.dart';
import 'Api/services/produit_service.dart';
import 'Api/services/category_service.dart';
import 'Api/provider/auth_controller.dart';
import 'controllers/boutique_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();

  // await FlutterSecureStorage().deleteAll(); // DEBUG ONLY — à ne pas décommenter en production

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

  // Initialize Auth Dependencies
  final apiClient = ApiClient();
  Get.put(apiClient, permanent: true);

  final authService = AuthService(apiClient);
  final boutiqueService = BoutiqueService(apiClient);
  final produitService = ProduitService(apiClient);
  final categoryService = CategoryService(apiClient);

  Get.put(authService, permanent: true);
  Get.put(boutiqueService, permanent: true);
  Get.put(produitService, permanent: true);
  Get.put(categoryService, permanent: true);

  Get.put(AuthController(authService), permanent: true);
  Get.put(BoutiqueController(boutiqueService), permanent: true);

  // Initialize global controllers
  Get.put(AppController());
  Get.put(ChatController());
  Get.put(DashboardController());

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
        theme: AppTheme.theme,
        initialRoute: '/splash',
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 280),
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child!,
          );
        },
        getPages: [
          GetPage(name: '/splash', page: () => const SplashScreen()),
          GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
          GetPage(name: '/auth', page: () => const AuthScreen()),
          GetPage(name: '/home', page: () => const HomeScreen()),
          GetPage(name: '/category', page: () => const CategoryScreen()),
          GetPage(name: '/search', page: () => const SearchScreen()),
          GetPage(
            name: '/product/:id',
            page: () => const ProductDetailScreen(),
          ),
          GetPage(name: '/chat/:id', page: () => const ChatScreen()),
          GetPage(name: '/messages', page: () => const MessagesScreen()),
          GetPage(name: '/order', page: () => const OrderCheckoutScreen()),
          GetPage(name: '/seller/:id', page: () => const SellerScreen()),
          GetPage(name: '/dashboard', page: () => const DashboardScreen()),
          GetPage(name: '/add-product', page: () => const AddProductScreen()),
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
          ),
          GetPage(
              name: '/notifications', page: () => const NotificationsScreen()),
          GetPage(name: '/profile', page: () => const ProfileScreen()),
          GetPage(name: '/profile-setup', page: () => const ProfileSetupScreen()),
          GetPage(
              name: '/shop-settings', page: () => const ShopSettingsScreen()),
          GetPage(name: '/settings', page: () => const SettingsScreen()),
          GetPage(name: '/favorites', page: () => const FavoritesScreen()),
          GetPage(name: '/orders', page: () => const OrdersScreen()),
          GetPage(name: '/help', page: () => const HelpScreen()),
        ],
      ),
    );
  }
}
