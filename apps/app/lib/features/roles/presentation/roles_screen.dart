import 'package:fitness_app/core/api_error.dart';
import 'package:fitness_app/core/confirm_delete.dart';
import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/features/roles/application/roles_providers.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _labelW = 220.0;
const _colW = 176.0;
const _headerH = 108.0;
const _groupH = 40.0;
const _rowH = 56.0;

class RolesScreen extends ConsumerStatefulWidget {
  const RolesScreen({super.key});

  @override
  ConsumerState<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends ConsumerState<RolesScreen> {
  List<Map<String, dynamic>> _roles = [];
  final Map<String, Map<String, dynamic>> _permBySlug = {};
  final Map<String, Set<String>> _slugs = {};
  final Map<String, TextEditingController> _nameCtrls = {};
  final Map<String, int> _saveGen = {};
  final _draftName = TextEditingController();
  final _draftSlugs = <String>{};
  bool _drafting = false;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _draftName.dispose();
    for (final c in _nameCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Set<String> _slugsOf(Map<String, dynamic> role) {
    return {
      for (final p in (role['permissions'] as List<dynamic>? ?? []))
        ((p as Map)['permission']?['slug'] as String?) ?? '',
    }..remove('');
  }

  List<Map<String, dynamic>> _sortedRoles(List<Map<String, dynamic>> roles) {
    final copy = List<Map<String, dynamic>>.from(roles);
    copy.sort((a, b) {
      final sysA = a['isSystem'] == true;
      final sysB = b['isSystem'] == true;
      if (sysA != sysB) {
        return sysA ? -1 : 1;
      }
      return (a['name'] as String).compareTo(b['name'] as String);
    });
    return copy;
  }

  void _replaceNameControllers(List<Map<String, dynamic>> roles) {
    for (final c in _nameCtrls.values) {
      c.dispose();
    }
    _nameCtrls.clear();
    for (final r in roles) {
      if (r['isSystem'] == true) {
        continue;
      }
      _nameCtrls[r['id'] as String] = TextEditingController(text: r['name'] as String);
    }
  }

  Future<void> _reload() async {
    try {
      final repo = ref.read(rolesRepositoryProvider);
      final roles = await repo.list();
      final perms = await repo.permissionCatalog();
      if (!mounted) {
        return;
      }
      final ordered = _sortedRoles(roles);
      _replaceNameControllers(ordered);
      setState(() {
        _roles = ordered;
        _permBySlug
          ..clear()
          ..addEntries(perms.map((p) => MapEntry(p['slug'] as String, p)));
        _slugs
          ..clear()
          ..addEntries(roles.map((r) => MapEntry(r['id'] as String, _slugsOf(r))));
        _loading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = AppLocalizations.of(context).rolesLoadFailed;
      });
    }
  }

  List<_VisRow> _visRows() {
    final rows = <_VisRow>[];
    for (final g in PermissionGroup.values) {
      rows.add(_VisRow.group(g));
      for (final slug in g.slugs) {
        final p = _permBySlug[slug];
        if (p != null) {
          rows.add(_VisRow.perm(p));
        }
      }
    }
    return rows;
  }

  String _groupTitle(AppLocalizations l10n, PermissionGroup g) {
    return switch (g) {
      PermissionGroup.schedule => l10n.permGroupSchedule,
      PermissionGroup.booking => l10n.permGroupBooking,
      PermissionGroup.clients => l10n.permGroupClients,
      PermissionGroup.ledger => l10n.permGroupLedger,
      PermissionGroup.roles => l10n.permGroupRoles,
    };
  }

  String _apiMessage(Object error, AppLocalizations l10n) {
    return switch (apiErrorCode(error)) {
      'LAST_MANAGE_ROLES' => l10n.lastManageRoles,
      'ROLE_IN_USE' => l10n.roleInUse,
      _ => l10n.saveFailed,
    };
  }

  void _toast(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _toggle(String roleId, String slug, bool value) async {
    final prev = Set<String>.from(_slugs[roleId] ?? {});
    final next = Set<String>.from(prev);
    if (value) {
      next.add(slug);
    } else {
      next.remove(slug);
    }
    setState(() => _slugs[roleId] = next);
    final gen = (_saveGen[roleId] ?? 0) + 1;
    _saveGen[roleId] = gen;
    try {
      await ref.read(rolesRepositoryProvider).update(roleId, slugs: next.toList());
    } catch (e) {
      if (!mounted || _saveGen[roleId] != gen) {
        return;
      }
      setState(() => _slugs[roleId] = prev);
      _toast(_apiMessage(e, AppLocalizations.of(context)));
    }
  }

  Future<void> _commitName(String roleId) async {
    final ctrl = _nameCtrls[roleId];
    if (ctrl == null) {
      return;
    }
    final role = _roles.where((r) => r['id'] == roleId).firstOrNull;
    if (role == null) {
      return;
    }
    final next = ctrl.text.trim();
    final current = role['name'] as String;
    if (next.isEmpty || next == current) {
      ctrl.text = current;
      return;
    }
    try {
      await ref.read(rolesRepositoryProvider).update(roleId, name: next);
      if (!mounted) {
        return;
      }
      setState(() => role['name'] = next);
      _toast(AppLocalizations.of(context).saved);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ctrl.text = current;
      _toast(_apiMessage(e, AppLocalizations.of(context)));
    }
  }

  Future<void> _deleteRole(Map<String, dynamic> role) async {
    final l10n = AppLocalizations.of(context);
    final sure = await confirmDelete(
      context,
      title: l10n.deleteRoleTitle,
      message: l10n.deleteRoleMessage(role['name'] as String),
    );
    if (sure != true || !mounted) {
      return;
    }
    try {
      await ref.read(rolesRepositoryProvider).delete(role['id'] as String);
      await _reload();
    } catch (e) {
      if (!mounted) {
        return;
      }
      _toast(_apiMessage(e, l10n));
    }
  }

  Future<void> _submitDraft() async {
    final l10n = AppLocalizations.of(context);
    final name = _draftName.text.trim();
    if (name.isEmpty) {
      _toast(l10n.roleName);
      return;
    }
    if (_draftSlugs.isEmpty) {
      _toast(l10n.createRoleNeedPermission);
      return;
    }
    try {
      await ref.read(rolesRepositoryProvider).create(name, _draftSlugs.toList());
      if (!mounted) {
        return;
      }
      _draftName.clear();
      _draftSlugs.clear();
      setState(() => _drafting = false);
      await _reload();
    } catch (e) {
      if (!mounted) {
        return;
      }
      _toast(_apiMessage(e, l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: l10n.createRole,
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => _drafting = true),
            ),
          ),
          Expanded(child: _body(l10n)),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null && _roles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_loadError!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                setState(() => _loading = true);
                _reload();
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }
    return _matrix(l10n);
  }

  Widget _matrix(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final vis = _visRows();
    final colCount = _roles.length + (_drafting ? 1 : 0);
    final gridW = colCount * _colW;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelW,
            child: Column(
              children: [
                const SizedBox(height: _headerH),
                for (final row in vis) _labelCell(row, l10n, theme),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: gridW < 1 ? _colW : gridW,
                child: Column(
                  children: [
                    SizedBox(
                      height: _headerH,
                      child: Row(
                        children: [
                          for (final role in _roles) _roleHeader(role, l10n),
                          if (_drafting) _draftHeader(l10n),
                        ],
                      ),
                    ),
                    for (final row in vis) _dataRow(row, theme, gridW < 1 ? _colW : gridW),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelCell(_VisRow row, AppLocalizations l10n, ThemeData theme) {
    if (row.group != null) {
      return Container(
        height: _groupH,
        width: _labelW,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Text(_groupTitle(l10n, row.group!), style: theme.textTheme.titleSmall),
      );
    }
    final p = row.perm!;
    return SizedBox(
      height: _rowH,
      width: _labelW,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              p['name'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              p['slug'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataRow(_VisRow row, ThemeData theme, double gridW) {
    if (row.group != null) {
      return Container(
        height: _groupH,
        width: gridW,
        color: theme.colorScheme.surfaceContainerHighest,
      );
    }
    final slug = row.perm!['slug'] as String;
    return SizedBox(
      height: _rowH,
      child: Row(
        children: [
          for (final role in _roles)
            SizedBox(
              width: _colW,
              height: _rowH,
              child: Center(
                child: Checkbox(
                  value: _slugs[role['id'] as String]?.contains(slug) ?? false,
                  onChanged: (v) => _toggle(role['id'] as String, slug, v == true),
                ),
              ),
            ),
          if (_drafting)
            SizedBox(
              width: _colW,
              height: _rowH,
              child: Center(
                child: Checkbox(
                  value: _draftSlugs.contains(slug),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _draftSlugs.add(slug);
                      } else {
                        _draftSlugs.remove(slug);
                      }
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _roleHeader(Map<String, dynamic> role, AppLocalizations l10n) {
    final system = role['isSystem'] == true;
    final id = role['id'] as String;
    return SizedBox(
      width: _colW,
      height: _headerH,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: system
            ? Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        role['name'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Chip(
                    label: Text('system'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrls[id],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(isDense: true),
                      onSubmitted: (_) => _commitName(id),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.save,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.check),
                    onPressed: () => _commitName(id),
                  ),
                  IconButton(
                    tooltip: l10n.delete,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteRole(role),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _draftHeader(AppLocalizations l10n) {
    return SizedBox(
      width: _colW,
      height: _headerH,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _draftName,
                autofocus: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: l10n.defaultRoleName,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: l10n.createRole,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.check),
                  onPressed: _submitDraft,
                ),
                IconButton(
                  tooltip: l10n.dismiss,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _draftName.clear();
                    _draftSlugs.clear();
                    setState(() => _drafting = false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VisRow {
  const _VisRow.group(this.group) : perm = null;
  const _VisRow.perm(this.perm) : group = null;

  final PermissionGroup? group;
  final Map<String, dynamic>? perm;
}
