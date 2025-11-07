import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/pages/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DatabaseReference _ref;
  String? _fullName;
  String? _email;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error = 'Sin sesión';
      _loading = false;
    } else {
      _ref = FirebaseDatabase.instance.ref('users/${user.uid}');
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final snap = await _ref.get();
      setState(() {
        _fullName = snap.child('fullName').value?.toString();
        _email = snap.child('email').value?.toString();
        _error = null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar el perfil';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(_error!, style: const TextStyle(color: AppColors.error))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_fullName != null && _fullName!.isNotEmpty ? '¡Hola, $_fullName!' : '¡Hola!'),
                      const SizedBox(height: 8),
                      if (_email != null)
                        Text(_email!, style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
      ),
    );
  }
}
