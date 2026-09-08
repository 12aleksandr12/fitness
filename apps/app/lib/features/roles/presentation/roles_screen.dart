import 'package:fitness_app/core/confirm_delete.dart';
import 'package:fitness_app/core/logout_button.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RolesScreen extends ConsumerStatefulWidget {
  const RolesScreen({super.key});

  @override
  ConsumerState<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends ConsumerState<RolesScreen> {
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _perms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final repo = ref.read(studioRepositoryProvider);
    final roles = await repo.roles();
    final perms = await repo.permissionCatalog();
    setState(() {
      _roles = roles;
      _perms = perms;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.roles),
        actions: [
          IconButton(
            tooltip: l10n.createRole,
            icon: const Icon(Icons.add),
            onPressed: () => _edit(null),
          ),
          const LogoutButton(),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final role in _roles)
                  ListTile(
                    title: Text(role['name'] as String),
                    subtitle: Text(
                      ((role['permissions'] as List<dynamic>?) ?? [])
                          .map((p) => (p as Map)['permission']?['slug'] ?? '')
                          .join(', '),
                    ),
                    trailing: role['isSystem'] == true ? const Chip(label: Text('system')) : null,
                    onTap: () => _edit(role),
                  ),
              ],
            ),
    );
  }

  Future<void> _edit(Map<String, dynamic>? role) async {
    final selected = <String>{
      if (role != null)
        for (final p in (role['permissions'] as List<dynamic>? ?? []))
          ((p as Map)['permission']?['slug'] as String?) ?? '',
    }..remove('');
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: role?['name'] as String? ?? l10n.defaultRoleName);
    final result = await showDialog<_RoleDialogResult>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(role == null ? l10n.newRole : l10n.rolePermissions(role['name'] as String)),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (role == null || role['isSystem'] != true)
                        TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l10n.roleName)),
                      for (final p in _perms)
                        CheckboxListTile(
                          title: Text(p['name'] as String),
                          subtitle: Text(p['slug'] as String),
                          value: selected.contains(p['slug']),
                          onChanged: (v) {
                            setLocal(() {
                              if (v == true) {
                                selected.add(p['slug'] as String);
                              } else {
                                selected.remove(p['slug'] as String);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (role != null && role['isSystem'] != true)
                  TextButton(
                    onPressed: () async {
                      final sure = await confirmDelete(
                        ctx,
                        title: l10n.deleteRoleTitle,
                        message: l10n.deleteRoleMessage(role['name'] as String),
                      );
                      if (sure != true || !ctx.mounted) {
                        return;
                      }
                      await ref.read(studioRepositoryProvider).deleteRole(role['id'] as String);
                      if (ctx.mounted) {
                        Navigator.pop(ctx, _RoleDialogResult.deleted);
                      }
                    },
                    child: Text(l10n.delete),
                  ),
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.dismiss)),
                FilledButton(onPressed: () => Navigator.pop(ctx, _RoleDialogResult.save), child: Text(l10n.save)),
              ],
            );
          },
        );
      },
    );
    if (result == _RoleDialogResult.deleted) {
      await _reload();
      return;
    }
    if (result != _RoleDialogResult.save) {
      return;
    }
    final slugs = selected.toList();
    if (role == null) {
      await ref.read(studioRepositoryProvider).createRole(nameCtrl.text.trim(), slugs);
    } else {
      await ref.read(studioRepositoryProvider).updateRole(role['id'] as String, slugs);
    }
    await _reload();
  }
}

enum _RoleDialogResult { save, deleted }
