import 'package:fitness_app/core/api_error.dart';
import 'package:fitness_app/core/confirm_delete.dart';
import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/core/require_permission.dart';
import 'package:fitness_app/core/theme.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/features/schedule/presentation/session_editor_dialog.dart';
import 'package:fitness_app/features/schedule/presentation/session_log_dialog.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ScheduleSessionCard extends ConsumerWidget {
  const ScheduleSessionCard({super.key, required this.session});

  final Map<String, dynamic> session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FitroomTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final bookings = (session['bookings'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final mine = bookings.where((b) => b['userId'] == user?.userId && b['status'] == 'booked').toList();
    final booked = session['bookedCount'] as int? ?? bookings.where((b) => b['status'] == 'booked' || b['status'] == 'attended').length;
    final capacity = session['capacity'] as int? ?? 0;
    final full = capacity > 0 && booked >= capacity;
    final title = (session['classType'] as Map<String, dynamic>?)?['name'] as String? ?? l10n.sessionFallback;
    final typeId = session['classTypeId'] as String? ??
        (session['classType'] as Map<String, dynamic>?)?['id'] as String? ??
        title;
    final accent = tokens.accentFor(typeId);
    final trainer = session['trainer'] as Map<String, dynamic>?;
    final starts = DateTime.parse(session['startsAt'] as String).toLocal();
    final ends = DateTime.parse(session['endsAt'] as String).toLocal();
    final timeRange = '${DateFormat('HH:mm').format(starts)}-${DateFormat('HH:mm').format(ends)}';
    final canBook = user?.can(Permissions.bookSelf) == true && mine.isEmpty && !full;

    return Container(
      height: 135,
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border.all(color: tokens.stroke),
        borderRadius: BorderRadius.circular(tokens.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  timeRange,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tokens.ink, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (trainer != null)
                  InkWell(
                    onTap: () => context.push('/people/${trainer['id']}'),
                    child: Text(
                      '${l10n.trainer}  ${trainer['name'] as String? ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: tokens.ink, fontSize: 16),
                    ),
                  )
                else
                  Text(
                    l10n.noTrainer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tokens.ink, fontSize: 16),
                  ),
                const Spacer(),
                Row(
                  children: [
                    _StatusChip(
                      mine: mine.isNotEmpty,
                      full: full,
                      booked: booked,
                      capacity: capacity,
                      onTap: () => _onChip(
                        context,
                        ref,
                        mine: mine,
                        canBook: canBook,
                      ),
                    ),
                    const Spacer(),
                    RequirePermission(
                      slug: Permissions.manageSchedule,
                      child: Tooltip(
                        message: l10n.editSession,
                        child: InkWell(
                          onTap: () => showSessionEditor(context: context, ref: ref, session: session),
                          child: const FigmaIcon(FigmaAssets.iconPen, size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: l10n.sessionLog,
                      child: InkWell(
                        onTap: () => showSessionLog(context, ref, session['id'] as String),
                        child: FigmaIcon(
                          mine.isNotEmpty
                              ? FigmaAssets.iconCalendar
                              : full
                                  ? FigmaAssets.iconPeople
                                  : FigmaAssets.iconNotebook,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 4,
            top: 14,
            child: Container(
              width: 4,
              height: 105,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onChip(
    BuildContext context,
    WidgetRef ref, {
    required List<Map<String, dynamic>> mine,
    required bool canBook,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (mine.isNotEmpty) {
      final comment = await confirmCancel(
        context,
        title: l10n.cancelOtherTitle,
        message: l10n.cancelOtherMessage(ref.read(authControllerProvider).valueOrNull?.name ?? ''),
        confirmLabel: l10n.cancel,
        commentLabel: l10n.commentOptional,
      );
      if (comment == null) {
        return;
      }
      try {
        await ref.read(studioRepositoryProvider).cancel(
              mine.first['id'] as String,
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
      return;
    }
    if (!canBook) {
      return;
    }
    await ref.read(studioRepositoryProvider).book(session['id'] as String);
    invalidateStudioWeek(ref);
  }
}

class ScheduleEmptySlot extends ConsumerWidget {
  const ScheduleEmptySlot({super.key, required this.startsAt});

  final DateTime startsAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FitroomTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius),
      side: BorderSide(color: tokens.stroke),
    );
    final slot = Material(
      color: tokens.surface,
      shape: shape,
      child: const SizedBox(height: 135, width: double.infinity),
    );
    return RequirePermission(
      slug: Permissions.manageSchedule,
      fallback: slot,
      child: Tooltip(
        message: l10n.newSession,
        child: Material(
          color: tokens.surface,
          shape: shape,
          child: InkWell(
            onTap: () => showSessionEditor(
              context: context,
              ref: ref,
              initialStarts: startsAt,
            ),
            customBorder: shape,
            child: const SizedBox(height: 135, width: double.infinity),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.mine,
    required this.full,
    required this.booked,
    required this.capacity,
    required this.onTap,
  });

  final bool mine;
  final bool full;
  final int booked;
  final int capacity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = FitroomTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final Color bg;
    final Color fg;
    final String label;
    if (mine) {
      bg = tokens.green;
      fg = tokens.onYellow;
      label = l10n.youAreBooked;
    } else if (full) {
      bg = tokens.muted;
      fg = tokens.onYellow;
      label = l10n.noSpots;
    } else {
      bg = tokens.paper;
      fg = tokens.onYellow;
      label = l10n.occupancyRatio(booked, capacity);
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        child: Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: tokens.ink),
            borderRadius: BorderRadius.circular(tokens.radiusSm),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
