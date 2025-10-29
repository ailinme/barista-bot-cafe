import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

// Ajusta según tu proyecto
// import 'package:barista_bot_cafe/screens/menu_screen.dart';
// import 'package:barista_bot_cafe/models/coffee.dart';

void main() {
  setUpAll(() async {
    // Cargar fuentes personalizadas si las usas
    await loadAppFonts();
  });

  group('Golden Tests - Menu Screen', () {
    
    testGoldens('MenuScreen se ve correcta en múltiples dispositivos', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          Device.phone,
          Device.iphone11,
          Device.tabletPortrait,
        ])
        ..addScenario(
          widget: const MenuScreenWrapper(),
          name: 'menu_con_productos',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'menu_screen_multiple_devices');
    });

    testGoldens('ProductCard se ve correcta', (tester) async {
      final coffee = Coffee(
        id: '1',
        name: 'Cappuccino',
        price: 50.0,
        description: 'Espresso con espuma de leche',
        imageUrl: 'https://example.com/cappuccino.jpg',
      );

      await tester.pumpWidgetBuilder(
        ProductCard(coffee: coffee),
        surfaceSize: const Size(400, 300),
      );

      await screenMatchesGolden(tester, 'product_card_cappuccino');
    });

    testGoldens('ProductCard con y sin imagen', (tester) async {
      final builder = GoldenBuilder.grid(
        columns: 2,
        widthToHeightRatio: 1,
      )
        ..addScenario(
          'Con imagen',
          ProductCard(
            coffee: Coffee(
              id: '1',
              name: 'Latte',
              price: 45.0,
              imageUrl: 'https://example.com/latte.jpg',
            ),
          ),
        )
        ..addScenario(
          'Sin imagen',
          ProductCard(
            coffee: Coffee(
              id: '2',
              name: 'Americano',
              price: 35.0,
            ),
          ),
        );

      await tester.pumpWidgetBuilder(builder.build());
      await screenMatchesGolden(tester, 'product_card_variations');
    });

    testGoldens('CartBadge con diferentes contadores', (tester) async {
      final builder = GoldenBuilder.grid(
        columns: 3,
        widthToHeightRatio: 1,
      )
        ..addScenario('Badge: 0', const CartBadge(itemCount: 0))
        ..addScenario('Badge: 5', const CartBadge(itemCount: 5))
        ..addScenario('Badge: 99+', const CartBadge(itemCount: 150));

      await tester.pumpWidgetBuilder(builder.build());
      await screenMatchesGolden(tester, 'cart_badge_states');
    });

    testGoldens('MenuScreen tema claro y oscuro', (tester) async {
      final menuScreen = const MenuScreenWrapper();

      final builder = GoldenBuilder.column()
        ..addScenario(
          'Tema Claro',
          MaterialApp(
            theme: ThemeData.light(),
            home: menuScreen,
          ),
        )
        ..addScenario(
          'Tema Oscuro',
          MaterialApp(
            theme: ThemeData.dark(),
            home: menuScreen,
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(400, 800),
      );

      await screenMatchesGolden(tester, 'menu_screen_themes');
    });

    testGoldens('Carrito vacío vs con items', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Carrito Vacío',
          const CartScreenEmpty(),
        )
        ..addScenario(
          'Carrito con Items',
          const CartScreenWithItems(),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(400, 800),
      );

      await screenMatchesGolden(tester, 'cart_screen_states');
    });
  });

  group('Golden Tests - Componentes Individuales', () {
    
    testGoldens('Botón primario en diferentes estados', (tester) async {
      final builder = GoldenBuilder.grid(
        columns: 3,
        widthToHeightRatio: 2,
      )
        ..addScenario(
          'Normal',
          ElevatedButton(
            onPressed: () {},
            child: const Text('Agregar'),
          ),
        )
        ..addScenario(
          'Deshabilitado',
          ElevatedButton(
            onPressed: null,
            child: const Text('Agregar'),
          ),
        )
        ..addScenario(
          'Con ícono',
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Agregar'),
          ),
        );

      await tester.pumpWidgetBuilder(builder.build());
      await screenMatchesGolden(tester, 'primary_button_states');
    });
  });
}

// WRAPPERS Y WIDGETS DE EJEMPLO - Ajusta según tu app
class MenuScreenWrapper extends StatelessWidget {
  const MenuScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
        actions: [
          const CartBadge(itemCount: 2),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          ProductCard(
            coffee: Coffee(
              id: '1',
              name: 'Latte',
              price: 45.0,
              description: 'Café con leche',
            ),
          ),
          ProductCard(
            coffee: Coffee(
              id: '2',
              name: 'Cappuccino',
              price: 50.0,
              description: 'Espresso con espuma',
            ),
          ),
        ],
      ),
    );
  }
}

class CartScreenEmpty extends StatelessWidget {
  const CartScreenEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Carrito')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 100),
            SizedBox(height: 16),
            Text('Tu carrito está vacío'),
          ],
        ),
      ),
    );
  }
}

class CartScreenWithItems extends StatelessWidget {
  const CartScreenWithItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Carrito')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.coffee),
                  title: Text('Latte'),
                  subtitle: Text('\$45.0'),
                  trailing: Text('x2'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Proceder al Pago'),
            ),
          ),
        ],
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

class ProductCard extends StatelessWidget {
  final Coffee coffee;

  const ProductCard({Key? key, required this.coffee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Icon(Icons.coffee, size: 50),
          Text(coffee.name),
          Text('\$${coffee.price}'),
          if (coffee.description != null) Text(coffee.description!),
        ],
      ),
    );
  }
}

class CartBadge extends StatelessWidget {
  final int itemCount;

  const CartBadge({Key? key, required this.itemCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    
    return Stack(
      children: [
        const Icon(Icons.shopping_cart),
        Positioned(
          right: 0,
          child: CircleAvatar(
            radius: 8,
            backgroundColor: Colors.red,
            child: Text(
              itemCount > 99 ? '99+' : '$itemCount',
              style: const TextStyle(fontSize: 8, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}