import 'package:flutter/material.dart';

import 'package:barista_bot_cafe/features/home/data/order_repository.dart';
import 'package:barista_bot_cafe/features/home/data/payment_api.dart';
import 'package:barista_bot_cafe/features/home/models/models.dart';
import 'package:barista_bot_cafe/features/home/utils/recommendations.dart';
import 'package:barista_bot_cafe/core/constants/colors.dart';
import 'package:barista_bot_cafe/shared/widgets/custom_button.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/order_status_screen.dart';
import 'package:barista_bot_cafe/core/logging/telemetry.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/beverage_detail_screen.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/payment_webview.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> items;

  const CartScreen({super.key, required this.items});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<CartItem> _items;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _items = List<CartItem>.from(widget.items);
  }

  double get _total => _items.fold(0, (sum, item) => sum + item.total);

  Future<void> _confirmOrder() async {
    if (_items.isEmpty) {
      setState(() => _error = 'Agrega al menos un producto.');
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _error = 'Inicia sesion para pagar.');
        return;
      }
      final pref = await PaymentApi.instance.createPreference(
        items: _items
            .map((i) => {
                  'id': i.beverage.id,
                  'title': i.beverage.name,
                  'quantity': i.quantity,
                  'unit_price': i.unitPrice,
                })
            .toList(),
        userId: user.uid,
      );
      final result = await Navigator.of(context).push<PaymentResult>(
        MaterialPageRoute(builder: (_) => PaymentWebView(checkoutUrl: pref.checkoutUrl)),
      );
      if (result == null || !result.approved) {
        setState(() => _error = 'El pago no se completó. No se generó el pedido.');
        return;
      }

      final handle = await OrderRepository.instance.createOrder(
        items: _items,
        total: _total,
        paymentStatus: 'approved',
        paymentMethod: 'mercadopago',
        paymentId: result.paymentId,
        preferenceId: pref.preferenceId,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderStatusScreen(orderId: handle.orderId, statusStream: handle.statusStream, items: _items),
        ),
      );
      Telemetry.track('order_created', data: {'orderId': handle.orderId, 'items': _items.length, 'total': _total});
      if (!mounted) return;
      Navigator.of(context).pop<List<CartItem>>([]);
    } catch (e) {
      setState(() => _error = 'No se pudo crear el pedido: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _simulatePayment() async {
    if (_items.isEmpty) {
      setState(() => _error = 'Agrega al menos un producto.');
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _error = 'Inicia sesion para continuar.');
        return;
      }
      final handle = await OrderRepository.instance.createOrder(
        items: _items,
        total: _total,
        paymentStatus: 'approved',
        paymentMethod: 'test',
        paymentId: 'test-${DateTime.now().millisecondsSinceEpoch}',
        preferenceId: 'test-local',
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderStatusScreen(orderId: handle.orderId, statusStream: handle.statusStream, items: _items),
        ),
      );
      Telemetry.track('order_created_test', data: {'orderId': handle.orderId, 'items': _items.length, 'total': _total});
      if (!mounted) return;
      Navigator.of(context).pop<List<CartItem>>([]);
    } catch (e) {
      setState(() => _error = 'Simulacion de pago fallida: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _removeAt(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _editItem(int index) async {
    final item = _items[index];
    final edited = await Navigator.of(context).push<CartItem>(
      MaterialPageRoute(
        builder: (_) => BeverageDetailScreen(
          beverage: item.beverage,
          recommendations: RecommendationEngine.recommendAddOns(item.beverage),
          initialItem: item,
        ),
      ),
    );
    if (edited != null) {
      setState(() => _items[index] = edited);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Carrito'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(widget.items),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.error)),
              ),
            if (_items.isEmpty)
              const Expanded(
                child: Center(child: Text('Tu carrito esta vacio.', style: TextStyle(color: AppColors.textLight))),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final extras = item.addOns.map((a) => a.name).join(', ');
                    final recText = RecommendationEngine.recommendAddOns(item.beverage)
                        .where((a) => !item.addOns.contains(a))
                        .map((a) => a.name)
                        .join(', ');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.beverage.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textLight)),
                                    const SizedBox(height: 4),
                                    Text('Tamano: ${item.size.label}', style: const TextStyle(color: AppColors.textSecondary)),
                                    if (extras.isNotEmpty) Text('Extras: $extras', style: const TextStyle(color: AppColors.textSecondary)),
                                    if (recText.isNotEmpty)
                                      Text('Sugerido: $recText', style: const TextStyle(color: AppColors.primary)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 96, maxWidth: 140),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(color: AppColors.textLight)),
                                    const SizedBox(height: 4),
                                    Text('\$${item.total.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(onPressed: () => _editItem(index), child: const Text('Editar')),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () => _removeAt(index),
                                          color: AppColors.error,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Eliminar',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      Text('\$${_total.toStringAsFixed(2)} MXN',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _submitting ? null : _simulatePayment,
                        child: const Text('Test: Simular pago'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop<List<CartItem>>(_items),
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: CustomButton(
          text: 'Confirmar pedido',
          onPressed: _submitting ? null : _confirmOrder,
          isLoading: _submitting,
        ),
      ),
    );
  }
}
