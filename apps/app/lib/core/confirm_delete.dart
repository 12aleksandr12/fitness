import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  String? message,
  String? confirmLabel,
}) async {
  final sure = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx);
      return AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.dismiss)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmLabel ?? l10n.delete)),
        ],
      );
    },
  );
  return sure == true;
}
