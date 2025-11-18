import 'package:flutter/material.dart';
import 'dart:async';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  int currentStep = 1;
  double progress = 0.6;
  int estimatedMinutes = 5;
  Timer? _timer;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> orderSteps = [
    {
      'title': 'Pedido confirmado',
      'time': '9:41 AM',
      'completed': true,
      'icon': Icons.check_circle,
      'color': Color(0xFF27AE60),
    },
    {
      'title': 'En preparación',
      'time': 'Tiempo estimado: 5 min',
      'completed': false,
      'icon': Icons.access_time,
      'color': Color(0xFFF39C12),
    },
    {
      'title': 'Listo para recoger',
      'time': 'Te notificaremos',
      'completed': false,
      'icon': Icons.coffee,
      'color': Color(0xFFBDC3C7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _startProgressSimulation();
  }

  void _startProgressSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          if (progress < 1.0) {
            progress += 0.1;
            if (estimatedMinutes > 0) {
              estimatedMinutes--;
            }
          } else {
            progress = 1.0;
            currentStep = 2;
            orderSteps[1]['completed'] = true;
            orderSteps[2]['completed'] = true;
            timer.cancel();
            _showReadyNotification();
          }
        });
      }
    });
  }

  void _showReadyNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF27AE60),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Tu pedido está listo!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Puedes recogerlo en BaristaBot Centro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pedido #${widget.orderId}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status principal
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF39C12),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF39C12).withOpacity(0.3 * _animationController.value),
                              blurRadius: 20,
                              spreadRadius: 10 * _animationController.value,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '⏱️',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentStep == 2 ? '¡Listo para recoger!' : 'Preparando tu pedido',
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentStep == 2 
                        ? 'Tu pedido está esperándote'
                        : 'El barista robot está trabajando en tu café',
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: const Color(0xFFECF0F1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF39C12)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${(progress * 100).toInt()}% completado',
                          style: const TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Timeline de estados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado del pedido',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...orderSteps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return _buildTimelineStep(
                        step,
                        isLast: index == orderSteps.length - 1,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Información adicional
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                  border: const Border(
                    left: BorderSide(
                      color: Color(0xFFF39C12),
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        currentStep == 2
                            ? 'Tu pedido está listo. ¡No olvides tu ticket de orden!'
                            : 'Tu pedido estará listo en aproximadamente $estimatedMinutes minutos. ¡Prepárate para disfrutar!',
                        style: const TextStyle(
                          color: Color(0xFF856404),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Contactar soporte
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67E22),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Contactar soporte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Ver detalles del pedido
                    },
                    child: const Text(
                      'Ver detalles del pedido',
                      style: TextStyle(
                        color: Color(0xFFE67E22),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(Map<String, dynamic> step, {required bool isLast}) {
    final completed = step['completed'] as bool;
    final color = step['color'] as Color;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: completed ? color : const Color(0xFFBDC3C7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: completed ? color : const Color(0xFFECF0F1),
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'],
                  style: TextStyle(
                    color: completed ? const Color(0xFF2C3E50) : const Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step['time'],
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}