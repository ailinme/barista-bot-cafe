import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:barista_bot_cafe/core/constants/colors.dart';
import 'package:barista_bot_cafe/core/logging/app_logger.dart';
import 'package:barista_bot_cafe/core/logging/telemetry.dart';
import 'package:barista_bot_cafe/core/logging/crash_reporter.dart';
import 'package:barista_bot_cafe/features/auth/presentation/pages/welcome_screen.dart';
import 'package:barista_bot_cafe/features/home/data/menu_repository.dart';
import 'package:barista_bot_cafe/features/home/models/models.dart';
import 'package:barista_bot_cafe/features/home/utils/recommendations.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/beverage_detail_screen.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/cart_screen.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/permissions_screen.dart';
import 'package:barista_bot_cafe/features/home/data/order_history_store.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/order_status_screen.dart';
import 'package:barista_bot_cafe/features/home/data/order_history_repository.dart';
import 'package:barista_bot_cafe/features/home/presentation/pages/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MenuRepository _menuRepo = const MenuRepository();
  late final DatabaseReference _userRef;

  String? _fullName;
  String? _email;
  List<Beverage> _menu = [];
  List<CartItem> _cart = [];
  List<OrderHistoryEntry> _history = [];
  bool _loading = true;
  String? _error;
  bool _seeding = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Sesion expirada';
        _loading = false;
      });
      return;
    }
    _userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

    try {
      final snap = await _userRef.get();
      _fullName = snap.child('fullName').value?.toString();
      _email = snap.child('email').value?.toString();
      _error = null;
    } catch (e, st) {
      _error = 'No se pudo cargar el perfil';
      AppLogger.logError('Load profile failed', e, st);
    }

    final menu = await _menuRepo.fetchMenu();
    final history = await OrderHistoryRepository.instance.fetch();
    setState(() {
      _menu = menu;
      _history = history;
      _loading = false;
    });
  }


  Future<void> _openDetail(Beverage beverage) async {
    Telemetry.track('open_beverage', data: {'id': beverage.id, 'name': beverage.name});
    final item = await Navigator.of(context).push<CartItem>(
      MaterialPageRoute(
        builder: (_) => BeverageDetailScreen(
          beverage: beverage,
          recommendations: RecommendationEngine.recommendAddOns(beverage),
        ),
      ),
    );
    if (item != null) {
      setState(() => _cart = [..._cart, item]);
      Telemetry.track('add_to_cart', data: {'id': item.beverage.id, 'size': item.size.id, 'addOns': item.addOns.map((a) => a.id).toList(), 'qty': item.quantity});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agregado al carrito: ${item.beverage.name}'), backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _openCart() async {
    final updated = await Navigator.of(context).push<List<CartItem>>(
      MaterialPageRoute(
        builder: (_) => CartScreen(items: _cart),
      ),
    );
    if (updated != null) {
      setState(() => _cart = updated);
      final history = await OrderHistoryRepository.instance.fetch();
      if (mounted) setState(() => _history = history);
    }
  }

  void _openHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final entries = _history;
        if (entries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historial de pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textLight)),
                SizedBox(height: 12),
                Text('Aun no tienes pedidos completados para repetir.', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Historial de pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textLight)),
                const SizedBox(height: 12),
                ...entries.map((e) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_itemsSummary(e), style: const TextStyle(color: AppColors.textLight)),
                      subtitle: Text(_fmt(e.completedAt), style: const TextStyle(color: AppColors.textSecondary)),
                      trailing: TextButton(
                        onPressed: () => _repeatOrder(e),
                        child: const Text('Repetir'),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  String _itemsSummary(OrderHistoryEntry entry) {
    if (entry.items.isEmpty) return entry.summary;
    return entry.items.map((i) => '${i.quantity}x ${i.beverage.name}').join(', ');
  }

  String _fmt(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$min';
  }

  void _repeatOrder(OrderHistoryEntry entry) {
    Navigator.of(context).pop(); // cerrar sheet
    final id = '${entry.id}-retry-${DateTime.now().millisecondsSinceEpoch}';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderStatusScreen(
          orderId: id,
          statusStream: const Stream.empty(),
          items: entry.items,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  Future<void> _sendTestError() async {
    await CrashReporter.recordError(Exception('Error controlado de prueba'), StackTrace.current, reason: 'Test error button');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error controlado enviado'), backgroundColor: AppColors.warning),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BaristaBot'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
          IconButton(icon: const Icon(Icons.bug_report_outlined), onPressed: _sendTestError),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historial de pedidos',
            onPressed: _openHistory,
          ),
          IconButton(
            icon: const Icon(Icons.privacy_tip_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PermissionsScreen())),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      floatingActionButton: _cart.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text('${_cart.length} ver carrito'),
              onPressed: _openCart,
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      const Text(
                        'Menu y personalizacion',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 12),
                      if (_menu.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('No hay productos en el menu.', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textLight)),
                              const SizedBox(height: 8),
                              const Text('Puedes cargar el menu demo en Realtime Database.', style: TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.cloud_upload_outlined),
                                label: Text(_seeding ? 'Cargando...' : 'Cargar menu demo'),
                                onPressed: _seeding ? null : _seedMenu,
                              ),
                            ],
                          ),
                        )
                      else
                        ..._menu.map((b) => _BeverageCard(
                              beverage: b,
                              onTap: () => _openDetail(b),
                            )),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final name = (_fullName != null && _fullName!.isNotEmpty) ? _fullName : null;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProfileScreen(
            fullName: _fullName,
            email: _email,
          ),
        ));
        await _loadAll();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name != null ? 'Hola, $name!' : 'Hola!',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight),
                  ),
                  if (_email != null)
                    Text(
                      _email!,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 4),
                  const Text('Personaliza tu bebida y confirma el pedido.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _seedMenu() async {
    setState(() => _seeding = true);
    try {
      await _menuRepo.seedFallback();
      await _loadAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu demo cargado en Realtime'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar el menu demo'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }
}

class _BeverageCard extends StatelessWidget {
  final Beverage beverage;
  final VoidCallback onTap;

  const _BeverageCard({
    required this.beverage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPrice = beverage.basePriceForSize(beverage.sizes.first).toStringAsFixed(2);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(beverage.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                    const SizedBox(height: 4),
                    Text(beverage.description, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('\$$defaultPrice MXN', style: const TextStyle(color: AppColors.textLight)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: beverage.tags
                .map((t) => Chip(
                      label: Text(t.toUpperCase()),
                      backgroundColor: AppColors.background,
                      labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onTap,
              child: const Text('Personalizar'),
            ),
          ),
        ],
      ),
    );
  }
}
