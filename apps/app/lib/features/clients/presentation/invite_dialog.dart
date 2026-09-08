import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/roles/application/roles_providers.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showInviteDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  late final List<Map<String, dynamic>> roles;
  try {
    roles = await ref.read(rolesRepositoryProvider).list();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
    return;
  }
  if (!context.mounted) {
    return;
  }
  if (roles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noRoles)));
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (ctx) => _InviteDialog(roles: roles),
  );
}

class _InviteDialog extends ConsumerStatefulWidget {
  const _InviteDialog({required this.roles});

  final List<Map<String, dynamic>> roles;

  @override
  ConsumerState<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<_InviteDialog> {
  final _email = TextEditingController();
  late String _roleId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _roleId = widget.roles.first['id'] as String;
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = l10n.checkRegisterFields);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final token = await ref.read(authRepositoryProvider).invite(email: email, roleId: _roleId);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.inviteSent),
          content: SelectableText(token),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: token));
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(l10n.copyToken),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = l10n.saveFailed;
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.inviteUser),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _email,
            enabled: !_saving,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.email),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _roleId,
            decoration: InputDecoration(labelText: l10n.role),
            items: [
              for (final role in widget.roles)
                DropdownMenuItem(
                  value: role['id'] as String,
                  child: Text(role['name'] as String? ?? ''),
                ),
            ],
            onChanged: _saving ? null : (value) => setState(() => _roleId = value ?? _roleId),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.dismiss),
        ),
        FilledButton(onPressed: _saving ? null : _send, child: Text(l10n.inviteUser)),
      ],
    );
  }
}
