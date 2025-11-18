// models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String icon;
  final String category;
  final List<String> sizes;
  final List<ProductExtra> extras;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
    required this.sizes,
    required this.extras,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      icon: json['icon'],
      category: json['category'],
      sizes: List<String>.from(json['sizes']),
      extras: (json['extras'] as List)
          .map((e) => ProductExtra.fromJson(e))
          .toList(),
    );
  }
}

class ProductExtra {
  final String name;
  final double price;

  ProductExtra({required this.name, required this.price});

  factory ProductExtra.fromJson(Map<String, dynamic> json) {
    return ProductExtra(
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }
}
