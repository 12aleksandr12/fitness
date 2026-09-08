import 'dart:typed_data';

import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userPhotoProvider = FutureProvider.family<Uint8List?, String>((ref, userId) {
  return ref.watch(studioRepositoryProvider).userPhoto(userId);
});
