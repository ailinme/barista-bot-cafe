import 'package:flutter/material.dart';
import 'package:barista_bot_cafe/features/home/presentation/home_screen.dart';
import 'package:barista_bot_cafe/features/products/presentation/product_detail_screen.dart';
import 'package:barista_bot_cafe/features/cart/presentation/cart_screen.dart'; 
import 'package:barista_bot_cafe/features/chat/presentation/ai_chat_screen.dart';
import 'package:barista_bot_cafe/features/loyalty/presentation/loyalty_screen.dart'; 
import 'package:barista_bot_cafe/features/orders/presentation/order_tracking_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/order-tracking';
  static const String orders = '/orders';
  static const String loyalty = '/loyalty';
  static const String profile = '/profile';
  static const String aiChat = '/ai-chat';
  static const String notifications = '/notifications';
  

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case productDetail:
        final product = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        );
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case aiChat:
        return MaterialPageRoute(builder: (_) => const AIChatScreen());
      case loyalty:
        return MaterialPageRoute(builder: (_) => const LoyaltyScreen());
      case orderTracking:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: orderId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta ${settings.name} no encontrada'),
            ),
          ),
        );
    }
  }
}