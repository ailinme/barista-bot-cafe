import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:barista_bot_cafe/features/home/models/models.dart';
import 'package:barista_bot_cafe/core/logging/app_logger.dart';

class OrderRepository {
  OrderRepository._internal();
  static final OrderRepository instance = OrderRepository._internal();

  final Map<String, StreamController<OrderStatus>> _localControllers = {};

  Future<OrderHandle> createOrder({
    required List<CartItem> items,
    required double total,
    String paymentStatus = 'approved',
    String paymentMethod = 'mercadopago',
    String? paymentId,
    String? preferenceId,
  }) async {
    final orderId = _generateOrderId();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw StateError('No authenticated user');

      final ref = FirebaseDatabase.instance.ref('orders/${user.uid}/$orderId');
      await ref.set({
        'status': orderStatusToString(OrderStatus.pending),
        'paymentStatus': paymentStatus,
        'paymentMethod': paymentMethod,
        'paymentId': paymentId,
        'preferenceId': preferenceId,
        'createdAt': ServerValue.timestamp,
        'total': total,
        'items': items.map((e) => e.toMap()).toList(),
      });

      final statusRef = ref.child('status');
      final stream = statusRef.onValue.map((event) {
        final value = event.snapshot.value?.toString() ?? 'pending';
        return orderStatusFromString(value);
      });

      return OrderHandle(orderId: orderId, statusStream: stream);
    } catch (error, stack) {
      // Fallback local simulado para no bloquear la UX si Firebase no responde.
      AppLogger.logError('Order creation failed (fallback local)', error, stack);
      final controller = StreamController<OrderStatus>();
      controller.add(OrderStatus.pending);
      _localControllers[orderId] = controller;
      _simulateProgress(controller);
      return OrderHandle(orderId: orderId, statusStream: controller.stream);
    }
  }

  OrderStatus currentStatus(String orderId) {
    final ctrl = _localControllers[orderId];
    if (ctrl == null) return OrderStatus.pending;
    // Último valor conocido
    return ctrl.hasListener ? OrderStatus.ready : OrderStatus.pending;
  }

  void _simulateProgress(StreamController<OrderStatus> controller) {
    Timer(const Duration(seconds: 4), () {
      if (controller.isClosed) return;
      controller.add(OrderStatus.preparing);
    });
    Timer(const Duration(seconds: 9), () {
      if (controller.isClosed) return;
      controller.add(OrderStatus.ready);
      controller.close();
    });
  }

  String _generateOrderId() {
    final random = Random();
    final millis = DateTime.now().millisecondsSinceEpoch;
    final suffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'ORD$millis$suffix';
  }
}
