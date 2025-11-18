// models/order.dart
class Order {
  final String id;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String? estimatedTime;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.estimatedTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      discount: json['discount'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
      status: OrderStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      estimatedTime: json['estimatedTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'estimatedTime': estimatedTime,
    };
  }
}

class OrderItem {
  final String productId;
  final String name;
  final String size;
  final int quantity;
  final double price;
  final List<String> extras;

  OrderItem({
    required this.productId,
    required this.name,
    required this.size,
    required this.quantity,
    required this.price,
    required this.extras,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      name: json['name'],
      size: json['size'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      extras: List<String>.from(json['extras']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'size': size,
      'quantity': quantity,
      'price': price,
      'extras': extras,
    };
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled,
}
