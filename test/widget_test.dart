// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barista_bot_cafe/main.dart';

void main() {
  testWidgets('App loads SplashScreen', (WidgetTester tester) async {
    // Ajusta el tamao de la ventana para evitar overflow en tests
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
    await tester.pumpWidget(const MyApp());

    // Se renderiza la app y muestra el splash con el logo/texto
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('BaristaBot'), findsOneWidget);

    // Avanza el tiempo para permitir que el Timer del SplashScreen expire
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
