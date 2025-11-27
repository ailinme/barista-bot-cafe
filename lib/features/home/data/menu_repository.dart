import 'package:firebase_database/firebase_database.dart';
import 'package:barista_bot_cafe/features/home/models/models.dart';

class MenuRepository {
  const MenuRepository();

  Future<List<Beverage>> fetchMenu() async {
    final ref = FirebaseDatabase.instance.ref('menu');
    final snap = await ref.get();
    if (!snap.exists) return _fallback();
    final map = snap.value as Map?;
    if (map == null) return _fallback();
    final list = <Beverage>[];
    map.forEach((key, value) {
      if (value is Map) {
        final bev = Beverage.fromMap(key.toString(), Map<String, dynamic>.from(value));
        if (bev != null) list.add(bev);
      }
    });
    if (list.isEmpty) return _fallback();
    return list;
  }

  Future<void> seedFallback() async {
    final ref = FirebaseDatabase.instance.ref('menu');
    await ref.set(_fallbackMap());
  }

  List<Beverage> _fallback() {
    return _fallbackMap().entries.map((e) => Beverage.fromMap(e.key, e.value)!).toList();
  }

  Map<String, Map<String, dynamic>> _fallbackMap() {
    return {
      'latte': {
        'name': 'Latte',
        'description': 'Espresso con leche vaporizada.',
        'basePrice': 1.0, // MXN
        'tags': ['cafe'],
        'sizes': [
          {'id': 'sm', 'label': 'Chico', 'priceDelta': 0},
          {'id': 'md', 'label': 'Mediano', 'priceDelta': 5},
          {'id': 'lg', 'label': 'Grande', 'priceDelta': 10},
        ],
        'addOns': [
          {'id': 'shot', 'name': 'Shot extra', 'price': 10},
          {'id': 'avena', 'name': 'Leche de avena', 'price': 8},
        ],
      },
      'cappuccino': {
        'name': 'Cappuccino',
        'description': 'Espresso con leche y espuma cremosa.',
        'basePrice': 45,
        'tags': ['cafe'],
        'sizes': [
          {'id': 'sm', 'label': 'Chico', 'priceDelta': 0},
          {'id': 'md', 'label': 'Mediano', 'priceDelta': 6},
          {'id': 'lg', 'label': 'Grande', 'priceDelta': 12},
        ],
        'addOns': [
          {'id': 'choc', 'name': 'Chocolate', 'price': 7},
          {'id': 'canela', 'name': 'Canela', 'price': 4},
        ],
      },
      'matcha': {
        'name': 'Matcha Latte',
        'description': 'Té verde matcha con leche.',
        'basePrice': 52,
        'tags': ['te'],
        'sizes': [
          {'id': 'sm', 'label': 'Chico', 'priceDelta': 0},
          {'id': 'md', 'label': 'Mediano', 'priceDelta': 7},
          {'id': 'lg', 'label': 'Grande', 'priceDelta': 14},
        ],
        'addOns': [
          {'id': 'miel', 'name': 'Miel de agave', 'price': 5},
          {'id': 'vainilla', 'name': 'Vainilla', 'price': 4},
        ],
      },
    };
  }
}
