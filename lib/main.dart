import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/themes/app_theme.dart';
import 'core/constants/strings.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'core/security/secret_store.dart';
import 'core/security/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (usa los archivos de configuración nativos).
  try {
    if (kIsWeb) {
      // Web/Chrome: requiere opciones explícitas
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
    } else {
      // Móvil: usa archivos nativos; si deseas, puedes usar currentPlatform
      await Firebase.initializeApp();
    }
  } catch (e) {
    // No bloquear la UI; se informará al usar Auth si no está configurado.
  }

  // Configurar almacén seguro según plataforma (móvil por defecto)
  if (kIsWeb) {
    // En Web: usar memoria (evitar almacenar secretos persistentes en navegador)
    SessionManager.instance.setStore(InMemorySecureStore());
  } else {
    SessionManager.instance.setStore(const SecureStorageStore());
  }

  // Configurar orientación de pantalla (solo portrait)
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar estilo de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
