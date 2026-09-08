import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Future<void> showSessionLog(BuildContext context, WidgetRef ref, String sessionId) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _SessionLogDialog(sessionId: sessionId),
  );
}

class _SessionLogDialog extends ConsumerWidget {
  const _SessionLogDialog({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loc = Localizations.localeOf(context).toString();
    final fmt = DateFormat('d MMM HH:mm', loc);
    return AlertDialog(
      title: Text(l10n.sessionLog),
      content: SizedBox(
        width: 420,
        child: FutureBuilder(
          future: ref.read(studioRepositoryProvider).sessionLog(sessionId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
            }
            final rows = snapshot.data!;
            if (rows.isEmpty) {
              return Text(l10n.sessionLogEmpty);
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final row in rows)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_line(l10n, row)),
                      subtitle: Text(_subtitle(fmt, row)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.dismiss)),
      ],
    );
  }
}

String _subtitle(DateFormat fmt, Map<String, dynamic> row) {
  final when = fmt.format(DateTime.parse(row['createdAt'] as String).toLocal());
  final comment = (row['comment'] as String?)?.trim();
  if (comment == null || comment.isEmpty) {
    return when;
  }
  return '$when\n$comment';
}

String _line(AppLocalizations l10n, Map<String, dynamic> row) {
  final actorMap = row['actor'] as Map<String, dynamic>?;
  final targetMap = row['target'] as Map<String, dynamic>?;
  final actor = actorMap?['name'] as String? ?? '';
  final target = targetMap?['name'] as String? ?? actor;
  final same = (actorMap?['id'] ?? actor) == (targetMap?['id'] ?? target);
  switch (row['action'] as String?) {
    case 'cancelled_other':
      return l10n.logCancelledOther(actor, target);
    case 'cancelled':
      return same ? l10n.logCancelledSelf(actor) : l10n.logCancelledOther(actor, target);
    case 'checked_in':
      return same ? l10n.logCheckedInSelf(actor) : l10n.logCheckedIn(actor, target);
    default:
      return same ? l10n.logBookedSelf(actor) : l10n.logBooked(actor, target);
  }
}
