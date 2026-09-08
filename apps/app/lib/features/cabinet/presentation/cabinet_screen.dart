import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CabinetScreen extends ConsumerWidget {
  const CabinetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кабинет')),
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
          final fmt = DateFormat('d MMM HH:mm', 'ru');
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Остаток визитов: $visits', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('Мои записи', style: Theme.of(context).textTheme.titleMedium),
              for (final b in bookings)
                ListTile(
                  title: Text(
                    () {
                      final session = b['session'] as Map<String, dynamic>?;
                      final classType = session?['classType'] as Map<String, dynamic>?;
                      return classType?['name']?.toString() ?? 'Занятие';
                    }(),
                  ),
                  subtitle: Text(
                    '${b['status']} · ${fmt.format(DateTime.parse((b['session'] as Map<String, dynamic>)['startsAt'] as String).toLocal())}',
                  ),
                ),
              const SizedBox(height: 16),
              Text('История баланса', style: Theme.of(context).textTheme.titleMedium),
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
