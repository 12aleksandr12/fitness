import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/core/theme.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final perms = user?.permissions ?? [];
    final l10n = AppLocalizations.of(context);
    final destinations = <_Dest>[
      _Dest('/schedule', Icons.calendar_month, l10n.schedule, null),
      _Dest('/cabinet', Icons.person, l10n.cabinet, null),
      if (perms.contains(Permissions.viewClients) || perms.contains(Permissions.adjustBalance))
        _Dest('/clients', Icons.groups, l10n.clients, Permissions.viewClients),
      if (perms.contains(Permissions.manageRoles))
        _Dest('/roles', Icons.admin_panel_settings, l10n.roles, Permissions.manageRoles),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = Breakpoints.isExpanded(constraints);
        final location = GoRouterState.of(context).uri.path;
        var index = destinations.indexWhere((d) => location.startsWith(d.path));
        if (index < 0) {
          index = 0;
        }

        final nav = destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                label: d.label,
              ),
            )
            .toList();

        final rail = destinations
            .map(
              (d) => NavigationRailDestination(
                icon: Icon(d.icon),
                label: Text(d.label),
              ),
            )
            .toList();

        void go(int i) => context.go(destinations[i].path);

        final bar = expanded
            ? null
            : NavigationBar(
                selectedIndex: index,
                destinations: nav,
                onDestinationSelected: go,
              );

        final body = expanded
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: go,
                    labelType: NavigationRailLabelType.all,
                    destinations: rail,
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: child),
                ],
              )
            : child;

        return Scaffold(
          body: body,
          bottomNavigationBar: bar,
        );
      },
    );
  }
}

class _Dest {
  const _Dest(this.path, this.icon, this.label, this.slug);
  final String path;
  final IconData icon;
  final String label;
  final String? slug;
}
