import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:barista_bot_cafe/core/constants/colors.dart';
import 'package:barista_bot_cafe/core/constants/strings.dart';
import 'package:barista_bot_cafe/shared/widgets/logo_widget.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/home_screen.dart';
import 'package:barista_bot_cafe/features/auth/presentation/pages/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Navegar a Welcome o Home según sesión después de 3 segundos
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Widget target = const WelcomeScreen();
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          target = const HomeScreen();
        }
      } catch (_) {
        target = const WelcomeScreen();
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => target),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: const LogoWidget(
              size: 150,
              showText: true,
              subtitle: AppStrings.appSlogan,
            ),
          ),
        ),
      ),
    );
  }
}
