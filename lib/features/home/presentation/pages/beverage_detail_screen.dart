import 'package:flutter/material.dart';

import 'package:barista_bot_cafe/features/home/models/models.dart';
import 'package:barista_bot_cafe/core/constants/colors.dart';
import 'package:barista_bot_cafe/shared/widgets/custom_button.dart';

class BeverageDetailScreen extends StatefulWidget {
  final Beverage beverage;
  final List<AddOn> recommendations;
  final CartItem? initialItem;

  const BeverageDetailScreen({
    super.key,
    required this.beverage,
    required this.recommendations,
    this.initialItem,
  });

  @override
  State<BeverageDetailScreen> createState() => _BeverageDetailScreenState();
}

class _BeverageDetailScreenState extends State<BeverageDetailScreen> {
  late BeverageSizeOption _selectedSize;
  final Set<String> _selectedAddOns = {};
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialItem != null) {
      _selectedSize = widget.initialItem!.size;
      _selectedAddOns.addAll(widget.initialItem!.addOns.map((a) => a.id));
      _quantity = widget.initialItem!.quantity;
    } else {
      _selectedSize = widget.beverage.sizes.first;
    }
  }

  double get _unitPrice {
    final base = widget.beverage.basePriceForSize(_selectedSize);
    final extras = widget.beverage.addOns
        .where((a) => _selectedAddOns.contains(a.id))
        .fold<double>(0, (sum, addOn) => sum + addOn.price);
    return base + extras;
  }

  double get _total => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final beverage = widget.beverage;
    final recommendedIds = widget.recommendations.map((e) => e.id).toSet();

    return Scaffold(
      appBar: AppBar(title: Text(beverage.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(beverage.description, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            const Text('Tamano', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: beverage.sizes
                  .map((s) => ChoiceChip(
                        label: Text('${s.label} (+${s.priceDelta.toStringAsFixed(2)} MXN)'),
                        selected: _selectedSize.id == s.id,
                        onSelected: (_) => setState(() => _selectedSize = s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Extras y personalizacion', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            if (beverage.addOns.isEmpty)
              const Text('Sin extras disponibles', style: TextStyle(color: AppColors.textSecondary))
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: beverage.addOns
                    .map(
                      (a) => FilterChip(
                        label: Text('${a.name} (+${a.price.toStringAsFixed(2)} MXN)'),
                        selected: _selectedAddOns.contains(a.id),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAddOns.add(a.id);
                            } else {
                              _selectedAddOns.remove(a.id);
                            }
                          });
                        },
                        avatar: recommendedIds.contains(a.id)
                            ? const Icon(Icons.star, color: AppColors.primary, size: 18)
                            : null,
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 16),
            const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total', style: TextStyle(color: AppColors.textSecondary)),
                    Text('\$${_total.toStringAsFixed(2)} MXN', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: CustomButton(
          text: widget.initialItem == null ? 'Agregar al carrito' : 'Guardar cambios',
          onPressed: () {
            final selectedAddOns = widget.beverage.addOns.where((a) => _selectedAddOns.contains(a.id)).toList();
            final item = CartItem(
              beverage: widget.beverage,
              size: _selectedSize,
              addOns: selectedAddOns,
              quantity: _quantity,
            );
            Navigator.of(context).pop(item);
          },
        ),
      ),
    );
  }
}
