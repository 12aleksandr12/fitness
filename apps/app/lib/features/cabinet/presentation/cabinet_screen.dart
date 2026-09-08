import 'package:fitness_app/core/app_languages.dart';
import 'package:fitness_app/core/logout_button.dart';
import 'package:fitness_app/core/language_picker.dart';
import 'package:fitness_app/core/locale_controller.dart';
import 'package:fitness_app/core/user_avatar.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinet), actions: const [LogoutButton()]),
      body: FutureBuilder(
        future: Future.wait([
          ref.read(studioRepositoryProvider).myPasses(),
          ref.read(studioRepositoryProvider).myBookings(),
          ref.read(studioRepositoryProvider).myLedger(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final passes = snapshot.data![0];
          final bookings = snapshot.data![1];
          final ledger = snapshot.data![2];
          final visits = passes.fold<int>(
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
              const SizedBox(height: 12),
              const Align(alignment: Alignment.centerLeft, child: LogoutButton(filled: true)),
              const SizedBox(height: 16),
              Text(l10n.remainingVisits(visits), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(l10n.myBookings, style: Theme.of(context).textTheme.titleMedium),
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
                    '${b['status']} · ${fmt.format(DateTime.parse((b['session'] as Map<String, dynamic>)['startsAt'] as String).toLocal())}',
                  ),
                ),
              const SizedBox(height: 16),
              Text(l10n.balanceHistory, style: Theme.of(context).textTheme.titleMedium),
              for (final e in ledger)
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
