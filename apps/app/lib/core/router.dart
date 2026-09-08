import 'package:fitness_app/core/app_shell.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/features/auth/presentation/login_screen.dart';
import 'package:fitness_app/features/cabinet/presentation/cabinet_screen.dart';
import 'package:fitness_app/features/clients/presentation/clients_screen.dart';
import 'package:fitness_app/features/roles/presentation/roles_screen.dart';
import 'package:fitness_app/features/schedule/presentation/schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/schedule',
    redirect: (context, state) {
      final loggingIn = state.uri.path == '/login';
      final user = auth.valueOrNull;
      final loading = auth.isLoading && !auth.hasValue && !auth.hasError;
      if (loading) {
        return null;
      }
      if (user == null && !loggingIn) {
        return '/login';
      }
      if (user != null && loggingIn) {
        return '/schedule';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      ShellRoute(
        builder: (c, s, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/schedule', builder: (c, s) => const ScheduleScreen()),
          GoRoute(path: '/cabinet', builder: (c, s) => const CabinetScreen()),
          GoRoute(path: '/clients', builder: (c, s) => const ClientsScreen()),
          GoRoute(path: '/roles', builder: (c, s) => const RolesScreen()),
        ],
      ),
    ],
  );
});
