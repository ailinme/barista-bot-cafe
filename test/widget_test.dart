import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barista_bot_cafe/main.dart';

void main() {
  group('Barista Bot Tests', () {
    
    testWidgets('App inicia correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Barista Bot Café'), findsOneWidget);
    });

    testWidgets('Botón de orden existe', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Muestra mensaje de bienvenida', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      expect(find.text('Bienvenido al Barista Bot'), findsWidgets);
    });

    testWidgets('Procesa una orden correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // Encuentra y presiona el botón de orden
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();
      
      // Verifica que se procese la orden
      expect(find.text('Orden procesada'), findsWidgets);
    });
  });
}