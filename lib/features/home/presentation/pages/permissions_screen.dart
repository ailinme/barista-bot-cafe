import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:barista_bot_cafe/core/constants/colors.dart';
import 'package:barista_bot_cafe/core/permissions/permission_service.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final Map<Permission, PermissionStatus> _statuses = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final map = <Permission, PermissionStatus>{};
    for (final p in _trackedPermissions) {
      map[p] = await p.status;
    }
    setState(() {
      _statuses
        ..clear()
        ..addAll(map);
      _loading = false;
    });
  }

  List<Permission> get _trackedPermissions => [Permission.notification];

  String _label(Permission p) {
    if (p == Permission.notification) return 'Notificaciones';
    return p.toString();
  }

  IconData _icon(Permission p) {
    if (p == Permission.notification) return Icons.notifications_active_outlined;
    return Icons.security;
  }

  Color _statusColor(PermissionStatus status) {
    if (status.isGranted) return AppColors.success;
    if (status.isDenied || status.isLimited) return AppColors.warning;
    return AppColors.error;
  }

  String _statusText(PermissionStatus status) {
    if (status.isGranted) return 'Permitido';
    if (status.isDenied) return 'Denegado';
    if (status.isRestricted) return 'Restringido';
    if (status.isLimited) return 'Limitado';
    if (status.isPermanentlyDenied) return 'Denegado permanente';
    return status.toString();
  }

  Future<void> _request(Permission p) async {
    await PermissionService.requestMany([p]);
    await _load();
    if (!mounted) return;
    final status = _statuses[p];
    if (status == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_label(p)}: ${_statusText(status)}'),
        backgroundColor: _statusColor(status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permisos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _trackedPermissions.length,
                itemBuilder: (context, index) {
                  final p = _trackedPermissions[index];
                  final status = _statuses[p];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(_icon(p), color: AppColors.primary),
                      title: Text(_label(p)),
                      subtitle: Text(
                        status != null ? _statusText(status) : 'Desconocido',
                        style: TextStyle(color: status != null ? _statusColor(status) : AppColors.textSecondary),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _request(p),
                        child: const Text('Solicitar'),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
