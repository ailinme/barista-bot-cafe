import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart'; // ← AGREGAR ESTE IMPORT

class LocalStorageService {
  // Guardar carrito
  Future<void> saveCart(List<OrderItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = items.map((e) => e.toJson()).toList();
    await prefs.setString('cart', jsonEncode(cartJson));
  }

  // Obtener carrito
  Future<List<OrderItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    if (cartString == null) return [];
    
    final List<dynamic> cartJson = jsonDecode(cartString);
    return cartJson.map((e) => OrderItem.fromJson(e)).toList();
  }

  // Limpiar carrito
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
  }

  // Puntos de lealtad
  Future<void> saveLoyaltyPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loyalty_points', points);
  }

  Future<int> getLoyaltyPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('loyalty_points') ?? 0;
  }

  // Favoritos
  Future<void> toggleFavorite(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    
    if (favorites.contains(productId)) {
      favorites.remove(productId);
    } else {
      favorites.add(productId);
    }
    
    await prefs.setStringList('favorites', favorites);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }

  // Verificar si es favorito
  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.contains(productId);
  }
}