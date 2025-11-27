import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:barista_bot_cafe/core/constants/colors.dart';
import 'package:barista_bot_cafe/core/constants/strings.dart';
import 'package:barista_bot_cafe/shared/widgets/custom_button.dart';
import 'package:barista_bot_cafe/shared/widgets/custom_text_field.dart';
import 'package:barista_bot_cafe/shared/widgets/logo_widget.dart';
import 'package:barista_bot_cafe/features/auth/presentation/pages/register_screen.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/home_screen.dart';
import 'package:barista_bot_cafe/core/security/validators.dart';
import 'package:barista_bot_cafe/core/security/rate_limiter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final RateLimiter _rateLimiter = RateLimiter(maxAttempts: 5, window: const Duration(minutes: 1), lockout: const Duration(seconds: 30));

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginSecure() async {
    if (_rateLimiter.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demasiados intentos. Intenta mas tarde.'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        _rateLimiter.registerAttempt(success: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesion exitoso'), backgroundColor: AppColors.success),
        );
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      } on FirebaseAuthException {
        _rateLimiter.registerAttempt(success: false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales incorrectas'), backgroundColor: AppColors.error),
        );
      } catch (_) {
        _rateLimiter.registerAttempt(success: false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrio un error al iniciar sesion'), backgroundColor: AppColors.error),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      _rateLimiter.registerAttempt(success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const LogoWidget(size: 120, showText: false),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.textSecondary.withOpacity(0.12)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(AppStrings.loginTitle, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                        const SizedBox(height: 8),
                        const Text(AppStrings.loginSubtitle, style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                        const SizedBox(height: 32),
                        CustomTextField(
                          hintText: AppStrings.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          autofillHints: const [AutofillHints.email],
                          trimOnChange: true,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintText: AppStrings.password,
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          autofillHints: const [AutofillHints.password],
                          validator: Validators.passwordLogin,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(text: AppStrings.login, onPressed: _loginSecure, isLoading: _isLoading),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No tienes cuenta? ', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
                        },
                        child: const Text('Registrate', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
