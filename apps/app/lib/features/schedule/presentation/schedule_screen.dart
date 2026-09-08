import 'package:fitness_app/core/confirm_delete.dart';
import 'package:fitness_app/core/logout_button.dart';
import 'package:fitness_app/core/locale_controller.dart';
import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/core/require_permission.dart';
import 'package:fitness_app/core/theme.dart';
import 'package:fitness_app/core/user_avatar.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/features/schedule/presentation/session_editor_dialog.dart';
import 'package:fitness_app/features/schedule/presentation/session_log_dialog.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weekSessionsProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.schedule),
        actions: [
          RequirePermission(
            slug: Permissions.manageSchedule,
            child: IconButton(
              tooltip: l10n.newSession,
              icon: const Icon(Icons.add),
              onPressed: () => showSessionEditor(context: context, ref: ref),
            ),
          ),
          const LogoutButton(),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.scheduleLoadFailed),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(weekSessionsProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (sessions) => LayoutBuilder(
          builder: (context, constraints) {
            if (Breakpoints.isExpanded(constraints)) {
              return ScheduleGrid(sessions: sessions);
            }
            return ScheduleList(sessions: sessions);
          },
        ),
      ),
    );
  }
}

class ScheduleList extends ConsumerWidget {
  const ScheduleList({super.key, required this.sessions});
  final List<Map<String, dynamic>> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = (ref.watch(localeControllerProvider).valueOrNull ?? const Locale('ru')).toString();
    final fmt = DateFormat('EEE d MMM HH:mm', loc);
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, i) => SessionTile(session: sessions[i], timeText: fmt.format(DateTime.parse(sessions[i]['startsAt'] as String).toLocal())),
    );
  }
}

class ScheduleGrid extends ConsumerWidget {
  const ScheduleGrid({super.key, required this.sessions});
  final List<Map<String, dynamic>> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = (ref.watch(localeControllerProvider).valueOrNull ?? const Locale('ru')).toString();
    final fmt = DateFormat('HH:mm', loc);
    final byDay = <String, List<Map<String, dynamic>>>{};
    for (final s in sessions) {
      final d = DateTime.parse(s['startsAt'] as String).toLocal();
      final key = DateFormat('yyyy-MM-dd').format(d);
      byDay.putIfAbsent(key, () => []).add(s);
    }
    final days = byDay.keys.toList()..sort();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final day in days)
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(DateFormat('EEE d MMM', loc).format(DateTime.parse(day))),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final s in byDay[day]!)
                        SessionTile(
                          session: s,
                          timeText: fmt.format(DateTime.parse(s['startsAt'] as String).toLocal()),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SessionTile extends ConsumerWidget {
  const SessionTile({super.key, required this.session, required this.timeText});
  final Map<String, dynamic> session;
  final String timeText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final bookings = (session['bookings'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final mine = bookings.where((b) => b['userId'] == user?.userId).toList();
    final booked = session['bookedCount'] ?? bookings.length;
    final capacity = session['capacity'] ?? 0;
    final l10n = AppLocalizations.of(context);
    final title = (session['classType'] as Map<String, dynamic>?)?['name'] ?? l10n.sessionFallback;
    final trainer = session['trainer'] as Map<String, dynamic>?;
    final canCancelOthers =
        user?.can(Permissions.bookOthers) == true || user?.can(Permissions.manageSchedule) == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('$title · $timeText', style: Theme.of(context).textTheme.titleSmall),
                ),
                IconButton(
                  tooltip: l10n.sessionLog,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.history),
                  onPressed: () => showSessionLog(context, ref, session['id'] as String),
                ),
                RequirePermission(
                  slug: Permissions.manageSchedule,
                  child: IconButton(
                    tooltip: l10n.editSession,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showSessionEditor(context: context, ref: ref, session: session),
                  ),
                ),
              ],
            ),
            Text('$booked / $capacity'),
            if (trainer != null)
              InkWell(
                onTap: () => context.push('/people/${trainer['id']}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      UserAvatar(
                        userId: trainer['id'] as String,
                        name: trainer['name'] as String? ?? '',
                        hasPhoto: trainer['hasPhoto'] == true,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.trainerLabel(trainer['name'] as String? ?? ''), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            if (bookings.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final b in bookings)
                    InputChip(
                      visualDensity: VisualDensity.compact,
                      avatar: UserAvatar(
                        userId: (b['user'] as Map<String, dynamic>?)?['id'] as String? ?? '',
                        name: (b['user'] as Map<String, dynamic>?)?['name'] as String? ?? '',
                        hasPhoto: (b['user'] as Map<String, dynamic>?)?['hasPhoto'] == true,
                        radius: 12,
                      ),
                      label: Text((b['user'] as Map<String, dynamic>?)?['name'] as String? ?? ''),
                      onDeleted: canCancelOthers && b['status'] == 'booked'
                          ? () async {
                              final name = (b['user'] as Map<String, dynamic>?)?['name'] as String? ?? '';
                              final sure = await confirmDelete(
                                context,
                                title: l10n.cancelOtherTitle,
                                message: l10n.cancelOtherMessage(name),
                                confirmLabel: l10n.cancel,
                              );
                              if (sure != true) {
                                return;
                              }
                              await ref.read(studioRepositoryProvider).cancel(b['id'] as String);
                              ref.invalidate(weekSessionsProvider);
                            }
                          : null,
                      onPressed: () {
                        final id = (b['user'] as Map<String, dynamic>?)?['id'] as String?;
                        if (id != null) {
                          context.push('/people/$id');
                        }
                      },
                    ),
                ],
              ),
            Wrap(
              spacing: 8,
              children: [
                RequirePermission(
                  slug: Permissions.bookSelf,
                  child: TextButton(
                    onPressed: mine.isNotEmpty
                        ? null
                        : () async {
                            await ref.read(studioRepositoryProvider).book(session['id'] as String);
                            ref.invalidate(weekSessionsProvider);
                          },
                    child: Text(l10n.book),
                  ),
                ),
                if (mine.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await ref.read(studioRepositoryProvider).cancel(mine.first['id'] as String);
                      ref.invalidate(weekSessionsProvider);
                    },
                    child: Text(l10n.cancel),
                  ),
                RequirePermission(
                  slug: Permissions.checkIn,
                  child: bookings.isEmpty
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: () async {
                            final bookedOnly = bookings.where((b) => b['status'] == 'booked');
                            for (final b in bookedOnly) {
                              await ref.read(studioRepositoryProvider).checkIn(b['id'] as String);
                            }
                            ref.invalidate(weekSessionsProvider);
                          },
                          child: Text(l10n.checkIn),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
