import 'dart:math' as math;

import 'package:fitness_app/core/theme.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/features/schedule/presentation/schedule_session_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _timeColWidth = 69.0;
const _minDayColWidth = 228.0;

class ScheduleGrid extends ConsumerWidget {
  const ScheduleGrid({super.key, required this.sessions});
  final List<Map<String, dynamic>> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = Localizations.localeOf(context).toString();
    final weekView = ref.watch(scheduleWeekViewProvider);
    final selected = ref.watch(scheduleSelectedDayProvider);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final days = [for (var i = 0; i < 7; i++) start.add(Duration(days: i))];
    final visibleDays = weekView ? days : [selected];

    final byKey = <String, Map<String, dynamic>>{};
    var minHour = 8;
    var maxHour = 12;
    for (final s in sessions) {
      final starts = DateTime.parse(s['startsAt'] as String).toLocal();
      final ends = DateTime.parse(s['endsAt'] as String).toLocal();
      minHour = minHour < starts.hour ? minHour : starts.hour;
      maxHour = maxHour > ends.hour ? maxHour : (ends.minute > 0 ? ends.hour + 1 : ends.hour);
      final key = '${DateFormat('yyyy-MM-dd').format(starts)}-${starts.hour}';
      byKey.putIfAbsent(key, () => s);
    }
    if (maxHour <= minHour) {
      maxHour = minHour + 1;
    }
    final hours = [for (var h = minHour; h < maxHour; h++) h];
    final tokens = FitroomTokens.of(context);
    final dayFmt = DateFormat('EEE d MMMM', loc);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minTable = _timeColWidth + visibleDays.length * _minDayColWidth;
          final tableWidth = math.max(constraints.maxWidth, minTable);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: _timeColWidth),
                      for (final day in visibleDays)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _DayHeader(
                              label: dayFmt.format(day).toUpperCase(),
                              selected: _sameDay(day, selected),
                              onTap: () => ref.read(scheduleSelectedDayProvider.notifier).state = day,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: hours.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final hour = hours[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: _timeColWidth,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 37),
                                child: Column(
                                  children: [
                                    Text(
                                      DateFormat('HH:mm').format(DateTime(2000, 1, 1, hour)),
                                      style: TextStyle(color: tokens.ink, fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                    Text('-', style: TextStyle(color: tokens.ink, fontSize: 16, fontWeight: FontWeight.w700)),
                                    Text(
                                      DateFormat('HH:mm').format(DateTime(2000, 1, 1, hour + 1)),
                                      style: TextStyle(color: tokens.ink, fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            for (final day in visibleDays)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _cell(byKey, day, hour),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cell(Map<String, Map<String, dynamic>> byKey, DateTime day, int hour) {
    final key = '${DateFormat('yyyy-MM-dd').format(day)}-$hour';
    final session = byKey[key];
    if (session == null) {
      return ScheduleEmptySlot(startsAt: DateTime(day.year, day.month, day.day, hour));
    }
    return ScheduleSessionCard(session: session);
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label, required this.selected, required this.onTap});

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
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: selected ? tokens.ink : tokens.surface),
            borderRadius: BorderRadius.circular(tokens.radius),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
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

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
