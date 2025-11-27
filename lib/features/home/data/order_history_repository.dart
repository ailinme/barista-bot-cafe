import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:barista_bot_cafe/features/home/models/models.dart';
import 'package:barista_bot_cafe/features/home/data/order_history_store.dart';

class OrderHistoryRepository {
  OrderHistoryRepository._internal();
  static final OrderHistoryRepository instance = OrderHistoryRepository._internal();

  final OrderHistoryStore _local = OrderHistoryStore.instance;

  Future<void> addEntry({
    required String orderId,
    required List<CartItem> items,
    required double total,
  }) async {
    final entry = OrderHistoryEntry(
      id: orderId,
      completedAt: DateTime.now(),
      summary: _summaryFor(items, total),
      items: items,
    );
    _local.add(entry);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final ref = FirebaseDatabase.instance.ref('orderHistory/${user.uid}/$orderId');
      await ref.set(_entryToMap(entry));
    } catch (_) {
      // Silencio: mantenemos fallback local.
    }
  }

  Future<List<OrderHistoryEntry>> fetch() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return _local.entries;
      final snap = await FirebaseDatabase.instance.ref('orderHistory/${user.uid}').get();
      if (!snap.exists) return _local.entries;
      final list = <OrderHistoryEntry>[];
      for (final child in snap.children) {
        final map = child.value as Map?;
        if (map == null) continue;
        list.add(_entryFromMap(child.key ?? 'ORD', map));
      }
      _local.replaceAll(list);
      return list;
    } catch (_) {
      return _local.entries;
    }
  }

  String _summaryFor(List<CartItem> items, double total) {
    final names = items.map((i) => '${i.quantity}x ${i.beverage.name}').join(', ');
    return '$names (\$${total.toStringAsFixed(2)})';
  }

  Map<String, dynamic> _entryToMap(OrderHistoryEntry e) {
    return {
      'id': e.id,
      'completedAt': e.completedAt.toIso8601String(),
      'summary': e.summary,
      'total': e.total,
      'items': e.items
          .map((i) => {
                'name': i.beverage.name,
                'beverageId': i.beverage.id,
                'size': i.size.label,
                'quantity': i.quantity,
                'addOns': i.addOns.map((a) => a.name).toList(),
                'unitPrice': i.unitPrice,
                'total': i.total,
              })
          .toList(),
    };
  }

  OrderHistoryEntry _entryFromMap(String id, Map data) {
    final itemsRaw = (data['items'] as List?) ?? [];
    final items = itemsRaw
        .map((e) => e is Map
            ? CartItem(
                beverage: Beverage(
                  id: e['beverageId']?.toString() ?? 'unknown',
                  name: e['name']?.toString() ?? 'Producto',
                  description: '',
                  basePrice: (e['unitPrice'] as num?)?.toDouble() ?? 0,
                  sizes: const [BeverageSizeOption(id: 'std', label: 'Std', priceDelta: 0)],
                  addOns: const [],
                ),
                size: BeverageSizeOption(id: 'std', label: e['size']?.toString() ?? 'Std', priceDelta: 0),
                addOns: const [],
                quantity: (e['quantity'] as num?)?.toInt() ?? 1,
              )
            : null)
        .whereType<CartItem>()
        .toList();
    return OrderHistoryEntry(
      id: id,
      completedAt: DateTime.tryParse(data['completedAt']?.toString() ?? '') ?? DateTime.now(),
      summary: data['summary']?.toString() ?? '',
      items: items,
      total: (data['total'] as num?)?.toDouble() ?? 0,
    );
  }
}
