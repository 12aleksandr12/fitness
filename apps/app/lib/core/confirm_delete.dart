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

/// Returns null if dismissed; empty string means confirmed without a comment.
Future<String?> confirmCancel(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String commentLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _ConfirmCancelDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      commentLabel: commentLabel,
    ),
  );
}

class _ConfirmCancelDialog extends StatefulWidget {
  const _ConfirmCancelDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.commentLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String commentLabel;

  @override
  State<_ConfirmCancelDialog> createState() => _ConfirmCancelDialogState();
}

class _ConfirmCancelDialogState extends State<_ConfirmCancelDialog> {
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.message),
          const SizedBox(height: 12),
          TextField(
            controller: _comment,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(labelText: widget.commentLabel),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.dismiss)),
        FilledButton(
          onPressed: () => Navigator.pop(context, _comment.text.trim()),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
