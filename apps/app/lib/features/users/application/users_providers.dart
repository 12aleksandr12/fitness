import 'package:fitness_app/core/providers.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/users/data/users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersRepositoryProvider = Provider(
  (ref) => UsersRepository(ref.watch(dioProvider)),
);

final myPassesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final auth = await ref.watch(authControllerProvider.future);
  if (auth == null) {
    return [];
  }
  return ref.read(usersRepositoryProvider).myPasses();
});

final myLedgerProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final auth = await ref.watch(authControllerProvider.future);
  if (auth == null) {
    return [];
  }
  return ref.read(usersRepositoryProvider).myLedger();
});
