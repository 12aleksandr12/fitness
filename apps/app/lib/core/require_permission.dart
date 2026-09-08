import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';

class RequirePermission extends ConsumerWidget {
  const RequirePermission({
    super.key,
    required this.slug,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final String slug;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(authControllerProvider).valueOrNull?.permissions ?? [];
    if (!perms.contains(slug)) {
      return fallback;
    }
    return child;
  }
}
