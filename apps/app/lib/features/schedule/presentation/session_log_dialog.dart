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
                      subtitle: Text(fmt.format(DateTime.parse(row['createdAt'] as String).toLocal())),
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

String _line(AppLocalizations l10n, Map<String, dynamic> row) {
  final actor = (row['actor'] as Map<String, dynamic>?)?['name'] as String? ?? '';
  final target = (row['target'] as Map<String, dynamic>?)?['name'] as String? ?? actor;
  switch (row['action'] as String?) {
    case 'cancelled_other':
      return l10n.logCancelledOther(actor, target);
    case 'cancelled':
      return l10n.logCancelled(actor, target);
    case 'checked_in':
      return l10n.logCheckedIn(actor, target);
    default:
      return l10n.logBooked(actor, target);
  }
}
