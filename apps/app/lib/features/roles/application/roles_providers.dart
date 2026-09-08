import 'package:fitness_app/core/providers.dart';
import 'package:fitness_app/features/roles/data/roles_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rolesRepositoryProvider = Provider(
  (ref) => RolesRepository(ref.watch(dioProvider)),
);
