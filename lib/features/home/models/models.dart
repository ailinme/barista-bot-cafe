import 'package:flutter/foundation.dart';

enum OrderStatus {
  pending,
  preparing,
  ready,
  completed,
  cancelled,
}

OrderStatus orderStatusFromString(String value) {
  switch (value) {
    case 'preparing':
      return OrderStatus.preparing;
    case 'ready':
      return OrderStatus.ready;
    case 'completed':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'pending':
    default:
      return OrderStatus.pending;
  }
}

String orderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'pending';
    case OrderStatus.preparing:
      return 'preparing';
    case OrderStatus.ready:
      return 'ready';
    case OrderStatus.completed:
      return 'completed';
    case OrderStatus.cancelled:
      return 'cancelled';
  }
}

class BeverageSizeOption {
  final String id;
  final String label;
  final double priceDelta;

  const BeverageSizeOption({
    required this.id,
    required this.label,
    required this.priceDelta,
  });
}

class AddOn {
  final String id;
  final String name;
  final double price;
  final List<String> tags; // usado para reglas simples de recomendación

  const AddOn({
    required this.id,
    required this.name,
    required this.price,
    this.tags = const [],
  });
}

class Beverage {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final List<String> tags;
  final List<BeverageSizeOption> sizes;
  final List<AddOn> addOns;
  final String? imageAsset;

  const Beverage({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.sizes,
    required this.addOns,
    this.imageAsset,
    this.tags = const [],
  });

  double basePriceForSize(BeverageSizeOption size) => basePrice + size.priceDelta;

  static Beverage? fromMap(String id, Map<String, dynamic> map) {
    final name = map['name']?.toString();
    final desc = map['description']?.toString() ?? '';
    final base = _toDouble(map['basePrice']);
    if (name == null || base == null) return null;

    final tags = (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    final sizesRaw = map['sizes'] as List?;
    final addOnsRaw = map['addOns'] as List?;

    final sizes = sizesRaw
            ?.map((e) => e is Map<String, dynamic> || e is Map
                ? BeverageSizeOption(
                    id: e['id']?.toString() ?? 'sm',
                    label: e['label']?.toString() ?? 'Chico',
                    priceDelta: _toDouble(e['priceDelta']) ?? 0,
                  )
                : null)
            .whereType<BeverageSizeOption>()
            .toList() ??
        <BeverageSizeOption>[
          const BeverageSizeOption(id: 'sm', label: 'Chico', priceDelta: 0),
          const BeverageSizeOption(id: 'md', label: 'Mediano', priceDelta: 0.5),
          const BeverageSizeOption(id: 'lg', label: 'Grande', priceDelta: 1.0),
        ];

    final addOns = addOnsRaw
            ?.map((e) => e is Map<String, dynamic> || e is Map
                ? AddOn(
                    id: e['id']?.toString() ?? 'extra',
                    name: e['name']?.toString() ?? 'Extra',
                    price: _toDouble(e['price']) ?? 0,
                    tags: (e['tags'] as List?)?.map((t) => t.toString()).toList() ?? const [],
                  )
                : null)
            .whereType<AddOn>()
            .toList() ??
        <AddOn>[];

    return Beverage(
      id: id,
      name: name,
      description: desc,
      basePrice: base,
      sizes: sizes,
      addOns: addOns,
      tags: tags,
      imageAsset: map['imageAsset']?.toString(),
    );
  }
}

class CartItem {
  final Beverage beverage;
  final BeverageSizeOption size;
  final List<AddOn> addOns;
  final int quantity;

  const CartItem({
    required this.beverage,
    required this.size,
    required this.addOns,
    this.quantity = 1,
  });

  double get unitPrice {
    final extras = addOns.fold<double>(0, (sum, addOn) => sum + addOn.price);
    return beverage.basePriceForSize(size) + extras;
  }

  double get total => unitPrice * quantity;

  CartItem copyWith({
    Beverage? beverage,
    BeverageSizeOption? size,
    List<AddOn>? addOns,
    int? quantity,
  }) {
    return CartItem(
      beverage: beverage ?? this.beverage,
      size: size ?? this.size,
      addOns: addOns ?? this.addOns,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'beverageId': beverage.id,
      'name': beverage.name,
      'size': {
        'id': size.id,
        'label': size.label,
        'priceDelta': size.priceDelta,
      },
      'addOns': addOns
          .map((a) => {
                'id': a.id,
                'name': a.name,
                'price': a.price,
              })
          .toList(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}

@immutable
class OrderHandle {
  final String orderId;
  final Stream<OrderStatus> statusStream;

  const OrderHandle({required this.orderId, required this.statusStream});
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
