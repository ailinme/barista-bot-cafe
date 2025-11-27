import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:barista_bot_cafe/core/constants/colors.dart';
import 'package:barista_bot_cafe/shared/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  final String? fullName;
  final String? email;

  const ProfileScreen({super.key, this.fullName, this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.fullName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user');
      final db = FirebaseDatabase.instance.ref('users/${user.uid}');
      await db.update({
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      await user.updateDisplayName(_nameController.text.trim());
      if (!mounted) return;
      setState(() => _message = 'Perfil actualizado');
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'No se pudo guardar');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user');
      await FirebaseDatabase.instance.ref('users/${user.uid}').remove();
      await user.delete();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'No se pudo eliminar la cuenta');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_message!, style: const TextStyle(color: AppColors.textSecondary)),
              ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefono',
                filled: true,
                fillColor: AppColors.surface,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: widget.email ?? ''),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Correo (solo lectura)',
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const Spacer(),
            CustomButton(
              text: 'Guardar perfil',
              onPressed: _loading ? null : _saveProfile,
              isLoading: _loading,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : _deleteAccount,
              child: const Text('Eliminar cuenta', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}
