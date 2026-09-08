import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/core/require_permission.dart';
import 'package:fitness_app/core/theme.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weekSessionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
        actions: [
          RequirePermission(
            slug: Permissions.manageSchedule,
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _createSlot(context, ref),
            ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
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

  Future<void> _createSlot(BuildContext context, WidgetRef ref) async {
    final types = await ref.read(studioRepositoryProvider).classTypes();
    if (!context.mounted || types.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc().add(const Duration(days: 1));
    final start = DateTime.utc(now.year, now.month, now.day, 10);
    await ref.read(studioRepositoryProvider).createSession({
      'classTypeId': types.first['id'],
      'startsAt': start.toIso8601String(),
      'endsAt': start.add(const Duration(hours: 1)).toIso8601String(),
      'capacity': 8,
      'room': 'Зал 1',
    });
    ref.invalidate(weekSessionsProvider);
  }
}

class ScheduleList extends ConsumerWidget {
  const ScheduleList({super.key, required this.sessions});
  final List<Map<String, dynamic>> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('EEE d MMM HH:mm', 'ru');
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
    final fmt = DateFormat('HH:mm', 'ru');
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
                  child: Text(DateFormat('EEE d MMM', 'ru').format(DateTime.parse(day))),
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
    final title = (session['classType'] as Map<String, dynamic>?)?['name'] ?? 'Занятие';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title · $timeText', style: Theme.of(context).textTheme.titleSmall),
            Text('$booked / $capacity'),
            if (bookings.isNotEmpty)
              Text(
                bookings.map((b) => (b['user'] as Map<String, dynamic>?)?['name'] ?? '').join(', '),
                style: Theme.of(context).textTheme.bodySmall,
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
                    child: const Text('Записаться'),
                  ),
                ),
                if (mine.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await ref.read(studioRepositoryProvider).cancel(mine.first['id'] as String);
                      ref.invalidate(weekSessionsProvider);
                    },
                    child: const Text('Отменить'),
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
                          child: const Text('Пришёл'),
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
