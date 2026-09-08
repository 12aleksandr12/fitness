import 'dart:typed_data';

import 'package:fitness_app/features/profile/application/photo_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAvatar extends ConsumerWidget {
  const UserAvatar({
    super.key,
    required this.userId,
    required this.name,
    this.hasPhoto = false,
    this.preview,
    this.radius = 18,
  });

  final String userId;
  final String name;
  final bool hasPhoto;
  final Uint8List? preview;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = preview == null && hasPhoto
        ? ref.watch(userPhotoProvider(userId))
        : const AsyncData<Uint8List?>(null);
    final bytes = preview ?? photo.valueOrNull;
    return CircleAvatar(
      radius: radius,
      backgroundImage: bytes != null ? MemoryImage(bytes) : null,
      child: bytes == null ? Text(_initials(name), style: TextStyle(fontSize: radius * 0.7)) : null,
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}
