import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Ajusta según tu proyecto
import 'package:barista_bot_cafe/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Barista Bot Café - Flujo E2E completo', () {
    
    testWidgets('Flujo completo: Ver menú -> Agregar café -> Ver carrito -> Checkout', 
      (tester) async {
      // Arrange - Iniciar la app
      app.main();
      await tester.pumpAndSettle();

      // Act & Assert - Paso 1: Verificar que estamos en la pantalla principal
      expect(find.text('Menú'), findsOneWidget);
      expect(find.byType(ProductCard), findsWidgets);

      // Act & Assert - Paso 2: Agregar primer café al carrito
      final firstCoffeeAddButton = find.byKey(const Key('add_to_cart_button')).first;
      await tester.tap(firstCoffeeAddButton);
      await tester.pumpAndSettle();

      // Verificar que el badge del carrito muestra 1
      expect(find.text('1'), findsOneWidget);

      // Act & Assert - Paso 3: Agregar segundo café
      final secondCoffeeAddButton = find.byKey(const Key('add_to_cart_button')).at(1);
      await tester.tap(secondCoffeeAddButton);
      await tester.pumpAndSettle();

      // Verificar que el badge ahora muestra 2
      expect(find.text('2'), findsOneWidget);

      // Act & Assert - Paso 4: Ir al carrito
      final cartIcon = find.byIcon(Icons.shopping_cart);
      await tester.tap(cartIcon);
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla del carrito
      expect(find.text('Mi Carrito'), findsOneWidget);
      expect(find.byType(CartItemWidget), findsNWidgets(2));

      // Act & Assert - Paso 5: Proceder al checkout
      final checkoutButton = find.text('Proceder al Pago');
      expect(checkoutButton, findsOneWidget);
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      // Verificar que llegamos a la pantalla de checkout
      expect(find.text('Checkout'), findsOneWidget);

      // Act & Assert - Paso 6: Completar orden
      final completeOrderButton = find.text('Completar Orden');
      await tester.tap(completeOrderButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar mensaje de éxito
      expect(find.text('¡Orden completada con éxito!'), findsOneWidget);
    });

    testWidgets('Buscar café específico en el menú', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Buscar "Latte"
      final searchField = find.byKey(const Key('search_field'));
      await tester.enterText(searchField, 'Latte');
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Latte'), findsWidgets);
      expect(find.textContaining('Cappuccino'), findsNothing);
    });

    testWidgets('Remover item del carrito', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Agregar café
      final addButton = find.byKey(const Key('add_to_cart_button')).first;
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Ir al carrito
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Remover el item
      final removeButton = find.byKey(const Key('remove_item_button'));
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tu carrito está vacío'), findsOneWidget);
    });

    testWidgets('Aplicar filtro por precio', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act - Abrir filtros
      final filterButton = find.byIcon(Icons.filter_list);
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Seleccionar rango de precio
      final priceRangeSlider = find.byType(RangeSlider);
      await tester.drag(priceRangeSlider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Aplicar filtro
      final applyButton = find.text('Aplicar');
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Assert - Verificar que solo se muestran cafés en el rango
      expect(find.byType(ProductCard), findsWidgets);
    });

    testWidgets('Navegar entre pestañas del bottom navigation', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act & Assert - Ir a Favoritos
      final favoritesTab = find.byIcon(Icons.favorite);
      await tester.tap(favoritesTab);
      await tester.pumpAndSettle();
      expect(find.text('Mis Favoritos'), findsOneWidget);

      // Act & Assert - Ir a Perfil
      final profileTab = find.byIcon(Icons.person);
      await tester.tap(profileTab);
      await tester.pumpAndSettle();
      expect(find.text('Mi Perfil'), findsOneWidget);

      // Act & Assert - Volver al menú
      final menuTab = find.byIcon(Icons.coffee);
      await tester.tap(menuTab);
      await tester.pumpAndSettle();
      expect(find.text('Menú'), findsOneWidget);
    });
  });

  group('Validaciones de formularios', () {
    
    testWidgets('Validar campos requeridos en checkout', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Agregar producto y ir a checkout
      await tester.tap(find.byKey(const Key('add_to_cart_button')).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proceder al Pago'));
      await tester.pumpAndSettle();

      // Act - Intentar completar orden sin llenar campos
      await tester.tap(find.text('Completar Orden'));
      await tester.pumpAndSettle();

      // Assert - Verificar mensajes de error
      expect(find.text('Campo requerido'), findsWidgets);
    });
  });
}

// WIDGETS Y CLASES DE EJEMPLO - Reemplaza con los de tu app
class ProductCard extends StatelessWidget {
  const ProductCard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container();
}