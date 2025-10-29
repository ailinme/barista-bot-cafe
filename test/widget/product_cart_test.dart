import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Ajusta según tu proyecto
// import 'package:barista_bot_cafe/widgets/product_card.dart';
// import 'package:barista_bot_cafe/models/coffee.dart';

void main() {
  group('ProductCard Widget Tests', () {
    
    testWidgets('ProductCard muestra información del café correctamente', (tester) async {
      // Arrange
      final coffee = Coffee(
        id: '1',
        name: 'Cappuccino',
        price: 50.0,
        description: 'Espresso con espuma de leche',
        imageUrl: 'https://example.com/cappuccino.jpg',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(coffee: coffee),
          ),
        ),
      );

      // Assert
      expect(find.text('Cappuccino'), findsOneWidget);
      expect(find.text('\$50.0'), findsOneWidget);
      expect(find.text('Espresso con espuma de leche'), findsOneWidget);
    });

    testWidgets('ProductCard muestra imagen del café', (tester) async {
      // Arrange
      final coffee = Coffee(
        id: '1',
        name: 'Latte',
        price: 45.0,
        imageUrl: 'https://example.com/latte.jpg',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(coffee: coffee),
          ),
        ),
      );

      // Assert - Buscar widget de imagen
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Botón de agregar al carrito está presente', (tester) async {
      // Arrange
      final coffee = Coffee(
        id: '1',
        name: 'Mocha',
        price: 55.0,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(coffee: coffee),
          ),
        ),
      );

      // Assert
      final addButton = find.byKey(const Key('add_to_cart_button'));
      expect(addButton, findsOneWidget);
    });

    testWidgets('Tap en botón agregar ejecuta callback', (tester) async {
      // Arrange
      bool wasPressed = false;
      final coffee = Coffee(id: '1', name: 'Americano', price: 35.0);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              coffee: coffee,
              onAddToCart: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('add_to_cart_button')));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });

    testWidgets('ProductCard muestra precio formateado correctamente', (tester) async {
      // Arrange
      final coffee = Coffee(
        id: '1',
        name: 'Flat White',
        price: 48.50,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(coffee: coffee),
          ),
        ),
      );

      // Assert - Verificar formato de precio
      expect(find.textContaining('48.5'), findsOneWidget);
    });

    testWidgets('ProductCard sin imagen muestra placeholder', (tester) async {
      // Arrange
      final coffee = Coffee(
        id: '1',
        name: 'Espresso',
        price: 30.0,
        imageUrl: null, // Sin imagen
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(coffee: coffee),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.coffee), findsOneWidget);
    });
  });
}

// WIDGET DE EJEMPLO - Reemplaza con tu ProductCard real
class ProductCard extends StatelessWidget {
  final Coffee coffee;
  final VoidCallback? onAddToCart;

  const ProductCard({
    Key? key,
    required this.coffee,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            if (coffee.imageUrl != null)
              Image.network(
                coffee.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.coffee, size: 150);
                },
              )
            else
              const Icon(Icons.coffee, size: 150),
            
            const SizedBox(height: 8),
            
            // Nombre
            Text(
              coffee.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Descripción
            if (coffee.description != null)
              Text(
                coffee.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Precio
                Text(
                  '\$${coffee.price}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                
                // Botón agregar
                ElevatedButton(
                  key: const Key('add_to_cart_button'),
                  onPressed: onAddToCart,
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Coffee {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;

  Coffee({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
  });
}