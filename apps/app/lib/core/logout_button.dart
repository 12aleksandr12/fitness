import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key, this.filled = false, this.iconOnly = false});

  final bool filled;
  final bool iconOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    void exit() => ref.read(authControllerProvider.notifier).logout();
    if (iconOnly) {
      return IconButton(
        tooltip: l10n.logout,
        onPressed: exit,
        icon: const Icon(Icons.logout),
      );
    }
    if (filled) {
      return FilledButton.icon(
        onPressed: exit,
        icon: const Icon(Icons.logout),
        label: Text(l10n.logout),
      );
    }
    return TextButton.icon(
      onPressed: exit,
      icon: const Icon(Icons.logout),
      label: Text(l10n.logout),
    );
  }
}
