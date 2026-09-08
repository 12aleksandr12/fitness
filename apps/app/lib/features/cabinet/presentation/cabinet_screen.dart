import 'package:fitness_app/core/app_languages.dart';
import 'package:fitness_app/core/language_picker.dart';
import 'package:fitness_app/core/locale_controller.dart';
import 'package:fitness_app/core/user_avatar.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/features/users/application/users_providers.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CabinetScreen extends ConsumerWidget {
  const CabinetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authControllerProvider).valueOrNull;
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider).valueOrNull ?? const Locale('ru');
    final bookings = _upcomingMine(ref.watch(myBookingsProvider).valueOrNull ?? []);
    final passes = ref.watch(myPassesProvider);
    final ledger = ref.watch(myLedgerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinet), actions: const [AppBarActions()]),
      body: passes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(l10n.noData)),
        data: (passRows) {
          final ledgerRows = ledger.valueOrNull ?? [];
          final visits = passRows.fold<int>(
            0,
            (sum, p) => sum + (p['remainingVisits'] as int? ?? 0),
          );
          final fmt = DateFormat('d MMM HH:mm', locale.toString());
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (me != null)
                ListTile(
                  leading: UserAvatar(userId: me.userId, name: me.name, hasPhoto: me.hasPhoto, radius: 28),
                  title: Text(me.name),
                  subtitle: Text(l10n.profilePage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/people/${me.userId}'),
                ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(nativeNameFor(locale)),
                onTap: () => showLanguagePicker(context, ref),
              ),
              const SizedBox(height: 16),
              Text(l10n.remainingVisits(visits), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(l10n.myBookings, style: Theme.of(context).textTheme.titleMedium),
              if (bookings.isEmpty)
                ListTile(title: Text(l10n.noUpcomingBookings)),
              for (final b in bookings)
                ListTile(
                  title: Text(
                    () {
                      final session = b['session'] as Map<String, dynamic>?;
                      final classType = session?['classType'] as Map<String, dynamic>?;
                      return classType?['name']?.toString() ?? l10n.sessionFallback;
                    }(),
                  ),
                  subtitle: Text(
                    '${_bookingStatus(b['status'] as String?, l10n)} · ${fmt.format(DateTime.parse((b['session'] as Map<String, dynamic>)['startsAt'] as String).toLocal())}',
                  ),
                ),
              const SizedBox(height: 16),
              Text(l10n.balanceHistory, style: Theme.of(context).textTheme.titleMedium),
              for (final e in ledgerRows)
                ListTile(
                  title: Text('${e['type']} · ${e['visits']}'),
                  subtitle: Text(e['note']?.toString() ?? ''),
                ),
            ],
          );
        },
      ),
    );
  }
}

List<Map<String, dynamic>> _upcomingMine(List<Map<String, dynamic>> rows) {
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final mine = rows.where((b) {
    final status = b['status'];
    if (status != 'booked' && status != 'attended') {
      return false;
    }
    final raw = (b['session'] as Map<String, dynamic>?)?['startsAt'] as String?;
    if (raw == null) {
      return false;
    }
    return !DateTime.parse(raw).toLocal().isBefore(today);
  }).toList();
  mine.sort((a, b) {
    final sa = DateTime.parse((a['session'] as Map<String, dynamic>)['startsAt'] as String);
    final sb = DateTime.parse((b['session'] as Map<String, dynamic>)['startsAt'] as String);
    return sa.compareTo(sb);
  });
  return mine;
}

String _bookingStatus(String? status, AppLocalizations l10n) {
  return switch (status) {
    'attended' => l10n.checkIn,
    'cancelled' => l10n.statusCancelled,
    _ => l10n.statusBooked,
  };
}
