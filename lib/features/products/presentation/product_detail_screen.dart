import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedSize = 'Chico';
  int quantity = 1;
  bool extraSugar = false;
  bool extraMilk = false;
  bool isFavorite = false;

  double get totalPrice {
    double base = widget.product['price'] as double;
    if (selectedSize == 'Mediano') base += 10;
    if (selectedSize == 'Grande') base += 20;
    if (extraSugar) base += 5;
    if (extraMilk) base += 10;
    return base * quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header con imagen
          Stack(
            children: [
              Container(
                height: 250,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF34495E), Color(0xFF2C3E50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.product['icon'] ?? '☕',
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product['name'] ?? 'Producto',
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${widget.product['description'] ?? 'Descripción del producto'}. Preparado con granos 100% arábica. Perfecto para comenzar el día con energía.',
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '\$${(widget.product['price'] ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFE67E22),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tamaños
                    const Text(
                      'Tamaño',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildSizeButton('Chico', '\$0'),
                        const SizedBox(width: 10),
                        _buildSizeButton('Mediano', '+\$10'),
                        const SizedBox(width: 10),
                        _buildSizeButton('Grande', '+\$20'),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Extras
                    const Text(
                      'Extras',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildExtraOption('Azúcar', 5, extraSugar, (value) {
                      setState(() {
                        extraSugar = value;
                      });
                    }),
                    _buildExtraOption('Leche extra', 10, extraMilk, (value) {
                      setState(() {
                        extraMilk = value;
                      });
                    }),
                    const SizedBox(height: 30),

                    // Cantidad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cantidad',
                          style: TextStyle(
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            _buildQuantityButton(Icons.remove, () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  color: Color(0xFF2C3E50),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            _buildQuantityButton(Icons.add, () {
                              setState(() {
                                quantity++;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Botón agregar al carrito
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${widget.product['name']} agregado al carrito',
                              ),
                              backgroundColor: const Color(0xFF27AE60),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE67E22),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Agregar al carrito - \$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeButton(String size, String price) {
    final isSelected = selectedSize == size;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSize = size;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE67E22) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFFE67E22) : const Color(0xFFBDC3C7),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              Text(
                size,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (price != '\$0')
                Text(
                  price,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtraOption(
    String name,
    int price,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: const Color(0xFFE67E22),
          ),
          Text(
            '$name +\$$price',
            style: const TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 35,
        height: 35,
        decoration: const BoxDecoration(
          color: Color(0xFFE67E22),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}