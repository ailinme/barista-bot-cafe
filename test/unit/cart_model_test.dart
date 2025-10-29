import 'package:flutter_test/flutter_test.dart';
// Ajusta estos imports según tu estructura de proyecto
//import 'package:barista_bot_cafe/models/coffee.dart';
//import 'package:barista_bot_cafe/models/cart.dart';


void main() {
  group('Cart Model Tests', () {
    
    test('Carrito inicia vacío', () {
      // Arrange
      final cart = Cart();
      
      // Assert
      expect(cart.items.length, 0);
      expect(cart.total, 0.0);
      expect(cart.isEmpty, true);
    });

    test('Agregar un café al carrito aumenta el total', () {
      // Arrange
      final cart = Cart();
      final coffee = Coffee(
        id: '1',
        name: 'Latte',
        price: 45.0,
        description: 'Café con leche',
      );
      
      // Act
      cart.addItem(coffee);
      
      // Assert
      expect(cart.items.length, 1);
      expect(cart.total, 45.0);
      expect(cart.isEmpty, false);
    });

    test('Agregar el mismo café dos veces aumenta cantidad', () {
      // Arrange
      final cart = Cart();
      final coffee = Coffee(
        id: '1',
        name: 'Cappuccino',
        price: 50.0,
        description: 'Espresso con espuma',
      );
      
      // Act
      cart.addItem(coffee);
      cart.addItem(coffee);
      
      // Assert
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 2);
      expect(cart.total, 100.0);
    });

    test('Remover café del carrito reduce el total', () {
      // Arrange
      final cart = Cart();
      final coffee = Coffee(
        id: '1',
        name: 'Americano',
        price: 35.0,
        description: 'Espresso con agua',
      );
      cart.addItem(coffee);
      
      // Act
      cart.removeItem(coffee.id);
      
      // Assert
      expect(cart.items.length, 0);
      expect(cart.total, 0.0);
      expect(cart.isEmpty, true);
    });

    test('Limpiar carrito elimina todos los items', () {
      // Arrange
      final cart = Cart();
      final coffee1 = Coffee(id: '1', name: 'Latte', price: 45.0);
      final coffee2 = Coffee(id: '2', name: 'Mocha', price: 55.0);
      
      cart.addItem(coffee1);
      cart.addItem(coffee2);
      
      // Act
      cart.clear();
      
      // Assert
      expect(cart.items.length, 0);
      expect(cart.total, 0.0);
    });

    test('Calcular total con descuento del 10%', () {
      // Arrange
      final cart = Cart();
      final coffee = Coffee(id: '1', name: 'Latte', price: 100.0);
      cart.addItem(coffee);
      
      // Act
      final totalConDescuento = cart.applyDiscount(0.10);
      
      // Assert
      expect(totalConDescuento, 90.0);
    });

    test('No se puede aplicar descuento mayor al 100%', () {
      // Arrange
      final cart = Cart();
      final coffee = Coffee(id: '1', name: 'Latte', price: 100.0);
      cart.addItem(coffee);
      
      // Act & Assert
      expect(
        () => cart.applyDiscount(1.5),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

// CLASES DE EJEMPLO - Reemplaza con tus modelos reales
class Coffee {
  final String id;
  final String name;
  final double price;
  final String? description;

  Coffee({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });
}

class CartItem {
  final Coffee coffee;
  int quantity;

  CartItem(this.coffee, {this.quantity = 1});
}

class Cart {
  final List<CartItem> items = [];

  bool get isEmpty => items.isEmpty;
  
  double get total {
    return items.fold(0, (sum, item) => sum + (item.coffee.price * item.quantity));
  }

  void addItem(Coffee coffee) {
    final existingIndex = items.indexWhere((item) => item.coffee.id == coffee.id);
    
    if (existingIndex != -1) {
      items[existingIndex].quantity++;
    } else {
      items.add(CartItem(coffee));
    }
  }

  void removeItem(String coffeeId) {
    items.removeWhere((item) => item.coffee.id == coffeeId);
  }

  void clear() {
    items.clear();
  }

  double applyDiscount(double discount) {
    if (discount > 1.0 || discount < 0) {
      throw ArgumentError('El descuento debe estar entre 0 y 1');
    }
    return total * (1 - discount);
  }
}