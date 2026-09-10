import 'package:fitness_app/core/api_error.dart';
import 'package:fitness_app/core/confirm_delete.dart';
import 'package:fitness_app/core/locale_controller.dart';
import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/core/require_permission.dart';
import 'package:fitness_app/core/theme.dart';
import 'package:fitness_app/core/user_avatar.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/features/schedule/presentation/schedule_week_grid.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = Breakpoints.isExpanded(constraints);
        return Scaffold(
          body: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.scheduleLoadFailed),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => invalidateStudioWeek(ref),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            data: (sessions) {
              if (!expanded) {
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: RequirePermission(
                        slug: Permissions.manageSchedule,
                        child: IconButton(
                          tooltip: l10n.newSession,
                          icon: const Icon(Icons.add),
                          onPressed: () => showSessionEditor(
                            context: context,
                            ref: ref,
                            initialStarts: _startsOnSelectedDay(ref),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: ScheduleList(sessions: sessions)),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _ScheduleToolbar(),
                  Expanded(child: ScheduleGrid(sessions: sessions)),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

DateTime _startsOnSelectedDay(WidgetRef ref) {
  final day = ref.read(scheduleSelectedDayProvider);
  return DateTime(day.year, day.month, day.day, 10);
}

class _ScheduleToolbar extends ConsumerWidget {
  const _ScheduleToolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = FitroomTokens.of(context);
    final loc = (ref.watch(localeControllerProvider).valueOrNull ?? const Locale('ru')).toString();
    final selected = ref.watch(scheduleSelectedDayProvider);
    final weekView = ref.watch(scheduleWeekViewProvider);
    final dateLabel = DateFormat('EEEE d MMMM', loc).format(selected).toUpperCase();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tokens.ink, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          RequirePermission(
            slug: Permissions.manageSchedule,
            child: IconButton(
              tooltip: l10n.newSession,
              icon: Icon(Icons.add, color: tokens.ink),
              onPressed: () => showSessionEditor(
                context: context,
                ref: ref,
                initialStarts: _startsOnSelectedDay(ref),
              ),
            ),
          ),
          _PeriodToggle(
            weekView: weekView,
            onDay: () => ref.read(scheduleWeekViewProvider.notifier).state = false,
            onWeek: () => ref.read(scheduleWeekViewProvider.notifier).state = true,
          ),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.weekView,
    required this.onDay,
    required this.onWeek,
  });

  final bool weekView;
  final VoidCallback onDay;
  final VoidCallback onWeek;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PeriodChip(label: l10n.periodDay, selected: !weekView, onTap: onDay),
        _PeriodChip(label: l10n.periodWeek, selected: weekView, onTap: onWeek),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = FitroomTokens.of(context);
    return Material(
      color: selected ? tokens.yellow : Colors.transparent,
      borderRadius: BorderRadius.circular(tokens.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: tokens.yellow),
            borderRadius: BorderRadius.circular(tokens.radius),
          ),
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? tokens.onYellow : tokens.ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
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
                    SessionPersonChip(
                      booking: b,
                      myUserId: user?.userId,
                      canCancelOthers: canCancelOthers,
                    ),
                ],
              ),
            RequirePermission(
              slug: Permissions.bookSelf,
              child: TextButton(
                onPressed: mine.isNotEmpty
                    ? null
                    : () async {
                        await ref.read(studioRepositoryProvider).book(session['id'] as String);
                        invalidateStudioWeek(ref);
                      },
                child: Text(l10n.book),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionPersonChip extends ConsumerWidget {
  const SessionPersonChip({
    super.key,
    required this.booking,
    required this.myUserId,
    required this.canCancelOthers,
  });

  final Map<String, dynamic> booking;
  final String? myUserId;
  final bool canCancelOthers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final person = booking['user'] as Map<String, dynamic>? ?? {};
    final name = person['name'] as String? ?? '';
    final userId = person['id'] as String?;
    final booked = booking['status'] == 'booked';
    final attended = booking['status'] == 'attended';
    final canCancel = booked && (userId == myUserId || canCancelOthers);
    return InputChip(
      visualDensity: VisualDensity.compact,
      tooltip: attended ? l10n.checkIn : l10n.profile,
      avatar: UserAvatar(
        userId: userId ?? '',
        name: name,
        hasPhoto: person['hasPhoto'] == true,
        radius: 12,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name),
          if (attended) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.check_circle,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
      onPressed: userId == null ? null : () => context.push('/people/$userId'),
      onDeleted: canCancel
          ? () async {
              final comment = await confirmCancel(
                context,
                title: l10n.cancelOtherTitle,
                message: l10n.cancelOtherMessage(name),
                confirmLabel: l10n.cancel,
                commentLabel: l10n.commentOptional,
              );
              if (comment == null) {
                return;
              }
              try {
                await ref.read(studioRepositoryProvider).cancel(
                      booking['id'] as String,
                      comment: comment.isEmpty ? null : comment,
                    );
                invalidateStudioWeek(ref);
              } catch (e) {
                if (!context.mounted) {
                  return;
                }
                final code = apiErrorCode(e);
                final text = switch (code) {
                  'CANCEL_TOO_LATE' => l10n.cancelTooLate,
                  'NOT_CANCELLABLE' => l10n.notCancellable,
                  _ => l10n.cancelFailed,
                };
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
              }
            }
          : null,
    );
  }
}
