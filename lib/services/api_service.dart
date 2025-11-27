import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barista_bot_cafe/models/product.dart'; // ← AGREGAR ESTE IMPORT
import 'package:barista_bot_cafe/models/order.dart';   // ← AGREGAR ESTE IMPORT

class ApiService {
  static const String baseUrl = 'YOUR_API_URL_HERE';
  static const String claudeApiKey = 'YOUR_CLAUDE_API_KEY_HERE';

  // Obtener token de autenticación
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Guardar token
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveAuthToken(data['token']);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': 'Credenciales inválidas'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Obtener productos
  Future<List<Product>> getProducts({String? category}) async {
    try {
      final token = await getAuthToken();
      final uri = category != null
          ? Uri.parse('$baseUrl/products?category=$category')
          : Uri.parse('$baseUrl/products');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear pedido
  Future<Order> createOrder(Order order) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(order.toJson()),
      );

      if (response.statusCode == 201) {
        return Order.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear pedido');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener historial de pedidos
  Future<List<Order>> getOrders() async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar pedidos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estado del pedido
  Future<Order> getOrderStatus(String orderId) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Order.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener estado del pedido');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Chat con Claude AI
  Future<String> sendChatMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': claudeApiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'system': '''Eres un asistente virtual de BaristaBot Café. 
          Ayuda a los clientes con información sobre productos, 
          horarios, lealtad y recomendaciones. Sé amigable y conciso.''',
          'messages': [
            {'role': 'user', 'content': message}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'];
      } else {
        throw Exception('Error en respuesta de AI');
      }
    } catch (e) {
      throw Exception('Error al comunicarse con AI: $e');
    }
  }
}