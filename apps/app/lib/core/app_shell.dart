import 'package:fitness_app/core/language_picker.dart';
import 'package:fitness_app/core/logout_button.dart';
import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/core/theme.dart';
import 'package:fitness_app/core/user_avatar.dart';
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
      _Dest('/schedule', FigmaAssets.navSchedule, FigmaAssets.navScheduleSelected, l10n.schedule, null),
      _Dest('/cabinet', FigmaAssets.navCabinet, FigmaAssets.navCabinet, l10n.cabinet, null),
      if (perms.contains(Permissions.viewClients) || perms.contains(Permissions.adjustBalance))
        _Dest('/clients', FigmaAssets.navClients, FigmaAssets.navClients, l10n.clients, Permissions.viewClients),
      if (perms.contains(Permissions.manageRoles))
        _Dest('/roles', FigmaAssets.navRoles, FigmaAssets.navRoles, l10n.roles, Permissions.manageRoles),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = Breakpoints.isExpanded(constraints);
        final location = GoRouterState.of(context).uri.path;
        var index = destinations.indexWhere((d) => location.startsWith(d.path));
        if (index < 0) {
          index = 0;
        }

        void go(int i) => context.go(destinations[i].path);

        final bar = expanded
            ? null
            : NavigationBar(
                selectedIndex: index,
                destinations: [
                  for (final d in destinations)
                    NavigationDestination(
                      icon: FigmaIcon(d.asset, size: 28),
                      selectedIcon: FigmaIcon(d.selectedAsset, size: 28),
                      label: d.label,
                    ),
                ],
                onDestinationSelected: go,
              );

        final header = _AppHeader(
          title: _titleFor(location, destinations, l10n),
          compact: !expanded,
        );
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Expanded(child: child),
          ],
        );
        final body = expanded
            ? Row(
                children: [
                  _FitroomRail(
                    destinations: destinations,
                    selectedIndex: index,
                    onSelect: go,
                  ),
                  Expanded(child: content),
                ],
              )
            : content;

        return Scaffold(
          body: body,
          bottomNavigationBar: bar,
        );
      },
    );
  }
}

String _titleFor(String location, List<_Dest> destinations, AppLocalizations l10n) {
  if (location.startsWith('/people')) {
    return l10n.profilePage;
  }
  for (final dest in destinations) {
    if (location.startsWith(dest.path)) {
      return dest.label;
    }
  }
  return l10n.schedule;
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.title, required this.compact});

  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = FitroomTokens.of(context);
    final canPop = GoRouter.of(context).canPop();
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 24, 16, compact ? 12 : 24, 8),
      child: Row(
        children: [
          if (canPop) ...[
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: Icon(Icons.arrow_back, color: tokens.ink),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tokens.ink, fontSize: compact ? 24 : 32),
            ),
          ),
          Flexible(child: _ShellUserBar(compact: compact)),
        ],
      ),
    );
  }
}

class _FitroomRail extends StatelessWidget {
  const _FitroomRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_Dest> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = FitroomTokens.of(context);
    return Container(
      width: 156,
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(right: BorderSide(color: tokens.stroke)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.logo,
              borderRadius: BorderRadius.circular(tokens.radius),
            ),
            child: Text(
              'FR',
              style: TextStyle(
                color: tokens.onYellow,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 36),
          for (var i = 0; i < destinations.length; i++) ...[
            if (i > 0) const SizedBox(height: 36),
            _RailItem(
              dest: destinations[i],
              selected: i == selectedIndex,
              onTap: () => onSelect(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.dest, required this.selected, required this.onTap});

  final _Dest dest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = FitroomTokens.of(context);
    final color = selected ? tokens.yellow : tokens.ink;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radius),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            FigmaIcon(
              selected ? dest.selectedAsset : dest.asset,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              dest.label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellUserBar extends ConsumerWidget {
  const _ShellUserBar({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final tokens = FitroomTokens.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconSize = compact ? 32.0 : 48.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (user != null) ...[
          UserAvatar(
            userId: user.userId,
            name: user.name,
            hasPhoto: user.hasPhoto,
            radius: compact ? 18 : 25,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              user.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.ink,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        FigmaIcon(FigmaAssets.iconSun, size: iconSize),
        SizedBox(width: compact ? 8 : 12),
        _ThemeTumbler(
          dark: dark,
          compact: compact,
          onChanged: (v) => ref.read(themeModeProvider.notifier).state =
              v ? ThemeMode.dark : ThemeMode.light,
        ),
        SizedBox(width: compact ? 8 : 12),
        FigmaIcon(FigmaAssets.iconMoon, size: iconSize),
        SizedBox(width: compact ? 16 : 24),
        if (compact) ...[
          const LanguageButton(iconOnly: true),
          const LogoutButton(iconOnly: true),
        ] else ...[
          const LanguageButton(),
          const LogoutButton(),
        ],
      ],
    );
  }
}

class _ThemeTumbler extends StatelessWidget {
  const _ThemeTumbler({
    required this.dark,
    required this.onChanged,
    this.compact = false,
  });

  final bool dark;
  final bool compact;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = FitroomTokens.of(context);
    final width = compact ? 52.0 : 76.0;
    final height = compact ? 32.0 : 48.0;
    final knob = compact ? 24.0 : 36.0;
    return GestureDetector(
      onTap: () => onChanged(!dark),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: tokens.paper,
          border: Border.all(color: tokens.onYellow),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        alignment: dark ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          width: knob,
          height: knob,
          decoration: BoxDecoration(
            color: tokens.yellow,
            shape: BoxShape.circle,
            border: Border.all(color: tokens.onYellow),
          ),
        ),
      ),
    );
  }
}

class _Dest {
  const _Dest(this.path, this.asset, this.selectedAsset, this.label, this.slug);
  final String path;
  final String asset;
  final String selectedAsset;
  final String label;
  final String? slug;
}
