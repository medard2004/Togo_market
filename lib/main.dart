import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'theme/app_theme.dart';
import 'controllers/app_controller.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/messages/messages_and_order_screen.dart';
import 'screens/profile/profile_and_more_screens.dart';

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
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 280),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/auth', page: () => const AuthScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/search', page: () => const SearchScreen()),
        GetPage(
          name: '/product/:id',
          page: () => const ProductDetailScreen(),
        ),
        GetPage(name: '/chat/:id', page: () => const ChatScreen()),
        GetPage(name: '/messages', page: () => const MessagesScreen()),
        GetPage(name: '/order', page: () => const OrderScreen()),
        GetPage(name: '/seller/:id', page: () => const SellerScreen()),
        GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/add-product', page: () => const AddProductScreen()),
        GetPage(
            name: '/notifications', page: () => const NotificationsScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/favorites', page: () => const FavoritesScreen()),
        GetPage(name: '/orders', page: () => const OrdersScreen()),
        GetPage(name: '/help', page: () => const HelpScreen()),
      ],
    );
  }
}
