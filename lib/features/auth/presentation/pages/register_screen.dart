import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:barista_bot_cafe/shared/pages/document_viewer.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/logo_widget.dart';
import '../../../../core/security/validators.dart';
import '../../../../core/permissions/permission_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Solicitar notificaciones JIT con degradación funcional.
      final granted = await PermissionService.requestNotificationsJIT();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificaciones desactivadas. Puedes habilitarlas luego.'),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }

      try {
        // Verificar inicialización de Firebase (especialmente en Web)
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final uid = cred.user?.uid;
        if (uid != null) {
          final db = FirebaseDatabase.instance.ref('users/$uid');
          await db.set({
            'fullName': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'createdAt': ServerValue.timestamp,
          });
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada exitosamente'), backgroundColor: AppColors.success),
        );
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error al crear la cuenta'), backgroundColor: AppColors.error),
        );
      } on FirebaseException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Firebase no está inicializado'), backgroundColor: AppColors.error),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error al crear la cuenta'), backgroundColor: AppColors.error),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const LogoWidget(size: 100, showText: false),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.registerTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.registerSubtitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Nombre completo
                        CustomTextField(
                          hintText: AppStrings.fullName,
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline),
                          autofillHints: const [AutofillHints.name],
                          validator: Validators.name,
                        ),
                        const SizedBox(height: 16),

                        // Correo electrónico
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

                        // Teléfono
                        CustomTextField(
                          hintText: AppStrings.phone,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 16),

                        // Contraseña
                        CustomTextField(
                          hintText: AppStrings.password,
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          autofillHints: const [AutofillHints.newPassword],
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 16),

                        // Enlaces a documentos
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: 'Revisa: '),
                                TextSpan(
                                  text: 'Protección de datos personales',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const DocumentViewerPage(
                                            title: 'Protección de datos personales',
                                            assetPath: 'assets/docs/datos_personales.md',
                                          ),
                                        ),
                                      );
                                    },
                                ),
                                const TextSpan(text: ' y '),
                                TextSpan(
                                  text: 'Política de privacidad',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const DocumentViewerPage(
                                            title: 'Política de privacidad',
                                            assetPath: 'assets/docs/privacidad.md',
                                          ),
                                        ),
                                      );
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Aceptar términos
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                              activeColor: AppColors.primary,
                            ),
                            const Expanded(
                              child: Text(
                                AppStrings.acceptTerms,
                                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Botón de registro
                        CustomButton(
                          text: AppStrings.register,
                          onPressed: _register,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Link para iniciar sesión
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Ya tienes cuenta? ',
                        style: TextStyle(color: AppColors.textLight, fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Inicia sesión',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
