import 'package:fitness_app/core/providers.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/schedule/data/studio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studioRepositoryProvider = Provider(
  (ref) => StudioRepository(ref.watch(dioProvider)),
);

final weekSessionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final auth = await ref.watch(authControllerProvider.future);
  if (auth == null) {
    return [];
  }
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day);
  return ref.read(studioRepositoryProvider).sessions(
        from: from,
        to: from.add(const Duration(days: 7)),
      );
});

final myBookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final auth = await ref.watch(authControllerProvider.future);
  if (auth == null) {
    return [];
  }
  return ref.read(studioRepositoryProvider).myBookings();
});

final scheduleWeekViewProvider = StateProvider<bool>((ref) => true);

final scheduleSelectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

void invalidateStudioWeek(WidgetRef ref) {
  ref.invalidate(weekSessionsProvider);
  ref.invalidate(myBookingsProvider);
}
