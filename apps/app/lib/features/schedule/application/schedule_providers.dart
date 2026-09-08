import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/schedule/data/studio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studioRepositoryProvider = Provider(
  (ref) => StudioRepository(ref.watch(dioProvider)),
);

final weekSessionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final now = DateTime.now().toUtc();
  final from = DateTime.utc(now.year, now.month, now.day);
  return ref.read(studioRepositoryProvider).sessions(
        from: from,
        to: from.add(const Duration(days: 7)),
      );
});
