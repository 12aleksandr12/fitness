import 'dart:typed_data';

import 'package:fitness_app/features/users/application/users_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userPhotoProvider = FutureProvider.family<Uint8List?, String>((ref, userId) {
  return ref.watch(usersRepositoryProvider).userPhoto(userId);
});
