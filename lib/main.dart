import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports de pantallas
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/products/presentation/product_detail_screen.dart';
import 'features/cart/presentation/cart_screen.dart';
import 'features/chat/presentation/ai_chat_screen.dart';
import 'features/loyalty/presentation/loyalty_screen.dart';
import 'features/orders/presentation/order_tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaristaBot Café',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2C3E50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE67E22),
        ),
        useMaterial3: true,
      ),
      // ⭐ PÁGINA INICIAL - Cambia esto según necesites
      home: const AuthChecker(), // Verifica si hay sesión
      // O puedes usar directamente:
      // home: const LoginScreen(),  // Para ir directo al login
      // home: const HomeScreen(),   // Para ir directo al home (testing)
      
      // Rutas definidas
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/chat': (context) => const AIChatScreen(),
        '/loyalty': (context) => const LoyaltyScreen(),
      },
    );
  }
}

// Widget que verifica si el usuario tiene sesión activa
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Verificar si hay token guardado
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    await Future.delayed(const Duration(seconds: 2)); // Simula splash screen
    
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Pantalla de carga (Splash Screen)
      return const SplashScreen();
    }

    // Si está logueado → Home, si no → Login
    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}

// Pantalla de Splash (opcional pero recomendada)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFE67E22),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '☕',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Título
              const Text(
                'BaristaBot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Subtítulo
              const Text(
                'Tu café perfecto, siempre',
                style: TextStyle(
                  color: Color(0xFFBDC3C7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE67E22)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}