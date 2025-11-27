import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  int totalPoints = 1250;
  int weeklyProgress = 2;
  String currentLevel = 'Café Lover';
  double levelProgress = 0.75;

  final List<Map<String, dynamic>> rewards = [
    {
      'name': 'Americano Gratis',
      'points': 500,
      'icon': '☕',
      'available': true,
    },
    {
      'name': 'Latte Gratis',
      'points': 800,
      'icon': '🥤',
      'available': true,
    },
    {
      'name': 'Descuento 20%',
      'points': 1500,
      'icon': '🎁',
      'available': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalPoints = prefs.getInt('loyalty_points') ?? 1250;
      weeklyProgress = prefs.getInt('weekly_progress') ?? 2;
    });
  }

  Future<void> _savePoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loyalty_points', points);
  }

  Future<void> _redeemReward(Map<String, dynamic> reward) async {
    if (totalPoints >= reward['points']) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Canjear ${reward['name']}'),
          content: Text(
            '¿Deseas canjear ${reward['points']} puntos por ${reward['name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
              ),
              child: const Text('Canjear'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() {
          totalPoints -= reward['points'] as int;
        });
        await _savePoints(totalPoints);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡${reward['name']} canjeado con éxito!'),
              backgroundColor: const Color(0xFF27AE60),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text('BaristaBot Rewards'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tarjeta de puntos
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34495E), Color(0xFF2C3E50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tus Puntos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$totalPoints',
                    style: const TextStyle(
                      color: Color(0xFFE67E22),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nivel: $currentLevel ☕',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE67E22)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '750 puntos para el siguiente nivel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Recompensas disponibles
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
                      'Recompensas disponibles',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...rewards.map((reward) => _buildRewardItem(reward)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Desafío semanal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          '🎯',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Desafío semanal',
                          style: TextStyle(
                            color: Color(0xFF27AE60),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Compra 3 cafés esta semana y gana 200 puntos extra',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: weeklyProgress / 3,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$weeklyProgress de 3 compras completadas',
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Cómo ganar puntos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¿Cómo ganar puntos?',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildPointInfo('10 puntos por cada \$1 gastado'),
                    _buildPointInfo('50 puntos de bono por cada 5 compras'),
                    _buildPointInfo('100 puntos extra en tu cumpleaños'),
                    _buildPointInfo('Puntos dobles los martes'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF2C3E50),
        selectedItemColor: const Color(0xFFE67E22),
        unselectedItemColor: const Color(0xFFBDC3C7),
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Puntos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildRewardItem(Map<String, dynamic> reward) {
    final canRedeem = totalPoints >= (reward['points'] as int);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFECF0F1)),
        ),
      ),
      child: Row(
        children: [
          Text(
            reward['icon'],
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward['name'],
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reward['points']} puntos',
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canRedeem ? () => _redeemReward(reward) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canRedeem ? const Color(0xFF27AE60) : const Color(0xFFBDC3C7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              canRedeem ? 'Canjear' : 'Necesitas más',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointInfo(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF7F8C8D),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}