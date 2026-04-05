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
        togoPage('/order', () => const OrderScreen()),
        togoPage('/seller/:id', () => const SellerScreen()),
        togoPage('/dashboard', () => const DashboardScreen()),
        togoPage('/store-settings', () => const StoreSettingsScreen()),
        togoPage('/add-product', () => const AddProductScreen(),
            style: TogoRouteStyle.modalLift),
        togoPage('/notifications', () => const NotificationsScreen()),
        togoPage('/profile', () => const ProfileScreen()),
        togoPage('/settings', () => const SettingsScreen()),
        togoPage('/favorites', () => const FavoritesScreen()),
        togoPage('/orders', () => const OrdersScreen()),
        togoPage('/help', () => const HelpScreen()),
      ],
    );
  }
}
