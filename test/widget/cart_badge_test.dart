import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Ajusta según tu proyecto
// import 'package:barista_bot_cafe/widgets/cart_badge.dart';

void main() {
  group('CartBadge Widget Tests', () {
    
    testWidgets('CartBadge muestra contador correcto', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CartBadge(itemCount: 3),
          ),
        ),
      );

      // Assert
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('CartBadge no se muestra cuando itemCount es 0', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CartBadge(itemCount: 0),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircleAvatar), findsNothing);
    });

    testWidgets('CartBadge muestra 99+ cuando hay más de 99 items', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CartBadge(itemCount: 150),
          ),
        ),
      );

      // Assert
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('CartBadge tiene color de fondo rojo', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CartBadge(itemCount: 5),
          ),
        ),
      );

      // Assert
      final badge = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(badge.backgroundColor, Colors.red);
    });

    testWidgets('Tap en CartBadge ejecuta callback', (tester) async {
      // Arrange
      bool wasTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CartBadge(
              itemCount: 2,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(wasTapped, true);
    });
  });
}

// WIDGET DE EJEMPLO - Reemplaza con tu CartBadge real
class CartBadge extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onTap;

  const CartBadge({
    super.key,
    required this.itemCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          const Icon(Icons.shopping_cart, size: 32),
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                itemCount > 99 ? '99+' : '$itemCount',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}