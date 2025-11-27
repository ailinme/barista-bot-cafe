import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:barista_bot_cafe/features/home/models/models.dart';
import 'package:barista_bot_cafe/features/home/utils/recommendations.dart';
import 'package:barista_bot_cafe/features/home/data/order_history_store.dart';
import 'package:barista_bot_cafe/features/home/data/order_history_repository.dart';
import 'package:barista_bot_cafe/core/constants/colors.dart';
import 'package:barista_bot_cafe/core/services/progress_api.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderId;
  final Stream<OrderStatus> statusStream;
  final List<CartItem> items;

  const OrderStatusScreen({
    super.key,
    required this.orderId,
    required this.statusStream,
    this.items = const [],
  });

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> with TickerProviderStateMixin {
  late final AnimationController _bobController;
  StreamSubscription<OrderStatus>? _subscription;
  final List<Timer> _timers = [];

  OrderStatus _status = OrderStatus.pending;
  late String _currentOrderId;
  late List<CartItem> _items;
  bool _historyLogged = false;
  List<double> _wave = const [0.35, 0.55, 0.42, 0.78, 0.38, 0.7, 0.5, 0.68];
  bool _waveFromApi = false;

  final List<OrderStatus> _steps = const [
    OrderStatus.pending,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    _currentOrderId = widget.orderId;
    _status = OrderStatus.pending;
    _items = List<CartItem>.from(widget.items);
    _bobController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _subscription = widget.statusStream.listen(_onStatus);
    _startLocalSimulation();
    _loadWave();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    for (final t in _timers) {
      t.cancel();
    }
    _bobController.dispose();
    super.dispose();
  }

  void _onStatus(OrderStatus incoming) {
    if (!mounted) return;
    setState(() {
      _status = incoming;
    });
    _logHistoryIfCompleted();
  }

  void _startLocalSimulation() {
    _clearTimers();
    _historyLogged = false;
    setState(() => _status = OrderStatus.pending);

    const schedule = [
      (OrderStatus.preparing, Duration(seconds: 4)),
      (OrderStatus.ready, Duration(seconds: 12)),
      (OrderStatus.completed, Duration(seconds: 20)),
    ];

    for (final entry in schedule) {
      final timer = Timer(entry.$2, () => _advanceTo(entry.$1));
      _timers.add(timer);
    }
  }

  void _advanceTo(OrderStatus target) {
    if (!mounted) return;
    setState(() {
      if (target.index > _status.index) {
        _status = target;
      }
    });
    _logHistoryIfCompleted();
  }

  void _logHistoryIfCompleted() {
    if (_status != OrderStatus.completed || _historyLogged) return;
    _historyLogged = true;
    final summary = RecommendationEngine.statusLabel(_status);
    setState(() {
      OrderHistoryRepository.instance.addEntry(
        orderId: _currentOrderId,
        items: _items,
        total: _items.fold(0, (sum, i) => sum + i.total),
      );
      OrderHistoryStore.instance.addFromStatus(
        _currentOrderId,
        _status,
        summary,
        items: _items,
        total: _items.fold(0, (sum, i) => sum + i.total),
      );
    });
  }

  void _clearTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  Future<void> _loadWave() async {
    final values = await ProgressApi.instance.fetchWave();
    if (!mounted) return;
    setState(() {
      _wave = values;
      _waveFromApi = true;
    });
  }

  double get _progress => _progressForStatus(_status);

  double _progressForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0.1;
      case OrderStatus.preparing:
        return 0.4;
      case OrderStatus.ready:
        return 0.7;
      case OrderStatus.completed:
        return 1.0;
      case OrderStatus.cancelled:
        return 1.0;
    }
  }


  @override
  Widget build(BuildContext context) {
    final label = RecommendationEngine.statusLabel(_status);
    final canFinish = _status == OrderStatus.completed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Estado del pedido')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: $_currentOrderId', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
                    const SizedBox(height: 6),
                    Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                    const SizedBox(height: 14),
                    _RobotStage(
                      progress: _progress,
                      bobAnimation: _bobController,
                      status: _status,
                      wave: _wave,
                      waveFromApi: _waveFromApi,
                    ),
                    const SizedBox(height: 16),
                    _StatusTimeline(
                      steps: _steps,
                      progress: _progress,
                      activeStatus: _status,
                    ),
                    const SizedBox(height: 12),
                    _StatusCards(
                      steps: _steps,
                      activeStatus: _status,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: canFinish ? () => Navigator.of(context).pop() : null,
                        icon: const Icon(Icons.flag),
                        label: const Text('Finalizar pedido'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Mant?n la app abierta para ver c?mo el robot barista concluye tu bebida en tiempo real.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RobotStage extends StatelessWidget {
  final double progress;
  final AnimationController bobAnimation;
  final OrderStatus status;
  final List<double> wave;
  final bool waveFromApi;

  const _RobotStage({
    required this.progress,
    required this.bobAnimation,
    required this.status,
    required this.wave,
    required this.waveFromApi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E1B2A), Color(0xFF143044)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Robot barista en accion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: waveFromApi ? Colors.green.withOpacity(0.15) : Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: waveFromApi ? Colors.greenAccent : Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(waveFromApi ? Icons.waves : Icons.offline_bolt_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(waveFromApi ? 'Datos API' : 'Sin API', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_robotCaption(status), style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: _Cup(progress: progress),
                    ),
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: bobAnimation,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _SignalLinePainter(t: bobAnimation.value, wave: wave),
                          );
                        },
                      ),
                    ),
                    AnimatedBuilder(
                      animation: bobAnimation,
                      builder: (context, child) {
                        final bob = lerpDouble(-8, 8, bobAnimation.value) ?? 0;
                        final armX = constraints.maxWidth * (0.1 + 0.8 * progress);
                        return Positioned(
                          top: 12 + bob,
                          left: armX.clamp(24, constraints.maxWidth - 64),
                          child: child!,
                        );
                      },
                      child: const _Drone(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _robotCaption(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Precalentando y calibrando el molino.';
      case OrderStatus.preparing:
        return 'Extrayendo espresso y vaporizando leche con precision.';
      case OrderStatus.ready:
        return 'Plating digital: sellando vaso y etiquetando.';
      case OrderStatus.completed:
        return 'Pedido listo para entregar.';
      case OrderStatus.cancelled:
        return 'Pedido cancelado.';
    }
  }
}

class _Drone extends StatelessWidget {
  const _Drone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10)],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.precision_manufacturing, color: AppColors.textLight),
          SizedBox(height: 4),
          Icon(Icons.coffee_maker, size: 14, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _Cup extends StatelessWidget {
  final double progress;

  const _Cup({required this.progress});

  @override
  Widget build(BuildContext context) {
    final fill = progress.clamp(0.0, 1.0);
    return Stack(
      children: [
        Container(
          width: 110,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))],
          ),
        ),
        Positioned(
          left: 6,
          right: 6,
          bottom: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              height: 100 * fill,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),
        if (fill > 0.2)
          Positioned(
            top: 6,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) {
                final delay = i * 150;
                return _SteamPuff(delay: delay);
              }),
            ),
          ),
      ],
    );
  }
}

class _SteamPuff extends StatefulWidget {
  final int delay;

  const _SteamPuff({required this.delay});

  @override
  State<_SteamPuff> createState() => _SteamPuffState();
}

class _SteamPuffState extends State<_SteamPuff> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..forward(from: widget.delay / 1400)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value + widget.delay / 1400) % 1.0;
        final opacity = (1 - progress).clamp(0.0, 1.0);
        final rise = 20 * progress;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, -rise),
            child: child,
          ),
        );
      },
      child: Container(
        width: 10,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}



class _SignalLinePainter extends CustomPainter {
  final double t;
  final List<double> wave;
  const _SignalLinePainter({required this.t, required this.wave});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final samples = wave.isEmpty ? [0.4, 0.6, 0.5, 0.7] : wave;
    final points = samples.length;
    for (int i = 0; i < points; i++) {
      final normX = i / (points - 1);
      final x = size.width * normX;
      final amp = samples[i];
      final y = size.height * (0.35 + 0.25 * (0.5 + 0.5 * t) * (amp - 0.5));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignalLinePainter oldDelegate) => oldDelegate.t != t || oldDelegate.wave != wave;
}

class _TimelinePainter extends CustomPainter {
  final double progress;

  const _TimelinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * 0.45;
    final basePaint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.18)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryDark],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), basePaint);
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width * progress.clamp(0.0, 1.0), centerY),
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) => oldDelegate.progress != progress;
}

class _StatusTimeline extends StatelessWidget {
  final List<OrderStatus> steps;
  final double progress;
  final OrderStatus activeStatus;

  const _StatusTimeline({
    required this.steps,
    required this.progress,
    required this.activeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.08)),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 8))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final stepWidth = width / (steps.length - 1);
          final indicatorX = width * progress.clamp(0.0, 1.0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Linea de proceso', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textLight)),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TimelinePainter(progress: progress),
                      ),
                    ),
                    ...List.generate(steps.length, (index) {
                      final left = (stepWidth * index).clamp(0, width - 1);
                      final label = RecommendationEngine.statusLabel(steps[index]);
                      final achieved = progress >= (index / (steps.length - 1)) - 0.01;
                      return Positioned(
                        left: left - 24,
                        bottom: 0,
                        width: 64,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              width: achieved ? 14 : 10,
                              height: achieved ? 14 : 10,
                              decoration: BoxDecoration(
                                color: achieved ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
                                shape: BoxShape.circle,
                                boxShadow: achieved
                                    ? const [
                                        BoxShadow(color: Color(0x33E67E22), blurRadius: 10, spreadRadius: 1),
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                          ],
                        ),
                      );
                    }),
                    Positioned(
                      left: indicatorX.clamp(0, width - 24),
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(RecommendationEngine.statusLabel(activeStatus), style: const TextStyle(color: AppColors.textLight)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusCards extends StatelessWidget {
  final List<OrderStatus> steps;
  final OrderStatus activeStatus;

  const _StatusCards({
    required this.steps,
    required this.activeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final descriptions = <OrderStatus, String>{
      OrderStatus.pending: 'Entramos tu orden al sistema del robot.',
      OrderStatus.preparing: 'El robot muele, calienta leche y mezcla ingredientes.',
      OrderStatus.ready: 'Bebida terminada y sellada para entrega.',
      OrderStatus.completed: 'Entrega confirmada. Gracias por ordenar!',
    };
    return Column(
      children: steps.map((status) {
        final active = activeStatus.index >= status.index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: active ? AppColors.surfaceLight : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.textSecondary.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(
                active ? Icons.check_circle_rounded : Icons.radio_button_checked,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      RecommendationEngine.statusLabel(status),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: active ? AppColors.textLight : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descriptions[status] ?? '',
                      style: TextStyle(
                        color: active ? AppColors.textPrimary : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (status == activeStatus)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.timelapse, color: AppColors.primary),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
