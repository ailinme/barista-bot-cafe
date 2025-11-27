import 'package:barista_bot_cafe/features/home/models/models.dart';

class RecommendationEngine {
  const RecommendationEngine._();

  /// Regla simple basada en tags del producto.
  static List<AddOn> recommendAddOns(Beverage beverage) {
    final tags = beverage.tags.toSet();
    return beverage.addOns.where((addOn) {
      if (addOn.tags.isEmpty) return true;
      return addOn.tags.any(tags.contains);
    }).take(2).toList();
  }

  static String statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.ready:
        return 'Listo para recoger';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}
