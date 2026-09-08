import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Роли'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _edit(null),
          ),
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
    final nameCtrl = TextEditingController(text: role?['name'] as String? ?? 'Ресепшен');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(role == null ? 'Новая роль' : 'Права: ${role['name']}'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (role == null || role['isSystem'] != true)
                        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Название')),
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
                      await ref.read(studioRepositoryProvider).deleteRole(role['id'] as String);
                      if (ctx.mounted) {
                        Navigator.pop(ctx, true);
                      }
                    },
                    child: const Text('Удалить'),
                  ),
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сохранить')),
              ],
            );
          },
        );
      },
    );
    if (ok != true) {
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
