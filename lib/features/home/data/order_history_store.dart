import 'package:barista_bot_cafe/features/home/models/models.dart';

class OrderHistoryEntry {
  final String id;
  final DateTime completedAt;
  final String summary;
  final List<CartItem> items;
  final double total;

  const OrderHistoryEntry({
    required this.id,
    required this.completedAt,
    required this.summary,
    this.items = const [],
    this.total = 0,
  });
}

class OrderHistoryStore {
  OrderHistoryStore._internal();
  static final OrderHistoryStore instance = OrderHistoryStore._internal();

  final List<OrderHistoryEntry> _entries = [];

  List<OrderHistoryEntry> get entries => List.unmodifiable(_entries);

  void add(OrderHistoryEntry entry) {
    _entries.insert(0, entry);
  }

  void replaceAll(List<OrderHistoryEntry> entries) {
    _entries
      ..clear()
      ..addAll(entries);
  }

  OrderHistoryEntry addFromStatus(String id, OrderStatus status, String summary, {List<CartItem> items = const [], double total = 0}) {
    final entry = OrderHistoryEntry(id: id, completedAt: DateTime.now(), summary: summary, items: items, total: total);
    add(entry);
    return entry;
  }
}
