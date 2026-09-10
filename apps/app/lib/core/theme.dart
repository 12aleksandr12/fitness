import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class Breakpoints {
  static const compact = 600.0;
  static const expanded = 900.0;

  static bool isExpanded(BoxConstraints c) => c.maxWidth >= expanded;
}

class FigmaAssets {
  static const navSchedule = 'assets/figma/nav_schedule.svg';
  static const navScheduleSelected = 'assets/figma/nav_schedule_selected.svg';
  static const navCabinet = 'assets/figma/nav_cabinet.svg';
  static const navClients = 'assets/figma/nav_clients.svg';
  static const navRoles = 'assets/figma/nav_roles.svg';
  static const iconNotebook = 'assets/figma/icon_notebook.svg';
  static const iconCalendar = 'assets/figma/icon_calendar.svg';
  static const iconPeople = 'assets/figma/icon_people.svg';
  static const iconPen = 'assets/figma/icon_pen.svg';
  static const iconSun = 'assets/figma/icon_sun.svg';
  static const iconMoon = 'assets/figma/icon_moon.svg';
}

class FitroomTokens extends ThemeExtension<FitroomTokens> {
  const FitroomTokens({
    required this.canvas,
    required this.surface,
    required this.stroke,
    required this.yellow,
    required this.ink,
    required this.muted,
    required this.blue,
    required this.braun,
    required this.violet,
    required this.green,
    required this.red,
    required this.interval,
    required this.paper,
    required this.onYellow,
    required this.logo,
    required this.radius,
    required this.radiusSm,
  });

  factory FitroomTokens.dark() => const FitroomTokens(
        canvas: Color(0xFF1A1A1A),
        surface: Color(0xFF2E2E2E),
        stroke: Color(0xFF424242),
        yellow: Color(0xFFFECE00),
        ink: Color(0xFFF6FAFA),
        paper: Color(0xFFF6FAFA),
        onYellow: Color(0xFF1A1A1A),
        logo: Color(0xFFD9D9D9),
        muted: Color(0xFF919190),
        blue: Color(0xFF5BA8B8),
        braun: Color(0xFFE27D52),
        violet: Color(0xFF9B8AC4),
        green: Color(0xFF55B47C),
        red: Color(0xFFF33A3A),
        interval: Color(0xFF6B82B8),
        radius: 8,
        radiusSm: 4,
      );

  factory FitroomTokens.light() => const FitroomTokens(
        canvas: Color(0xFFF6FAFA),
        surface: Color(0xFFFFFFFF),
        stroke: Color(0xFF424242),
        yellow: Color(0xFFFECE00),
        ink: Color(0xFF1A1A1A),
        paper: Color(0xFFF6FAFA),
        onYellow: Color(0xFF1A1A1A),
        logo: Color(0xFFD9D9D9),
        muted: Color(0xFF919190),
        blue: Color(0xFF5BA8B8),
        braun: Color(0xFFE27D52),
        violet: Color(0xFF9B8AC4),
        green: Color(0xFF55B47C),
        red: Color(0xFFF33A3A),
        interval: Color(0xFF6B82B8),
        radius: 8,
        radiusSm: 4,
      );

  final Color canvas;
  final Color surface;
  final Color stroke;
  final Color yellow;
  final Color ink;
  final Color muted;
  final Color blue;
  final Color braun;
  final Color violet;
  final Color green;
  final Color red;
  final Color interval;
  final Color paper;
  final Color onYellow;
  final Color logo;
  final double radius;
  final double radiusSm;

  static FitroomTokens of(BuildContext context) {
    return Theme.of(context).extension<FitroomTokens>() ?? FitroomTokens.dark();
  }

  List<Color> get accents => [blue, braun, violet, green, red, interval];

  Color accentFor(String key) => accents[key.hashCode.abs() % accents.length];

  @override
  FitroomTokens copyWith({
    Color? canvas,
    Color? surface,
    Color? stroke,
    Color? yellow,
    Color? ink,
    Color? muted,
    Color? blue,
    Color? braun,
    Color? violet,
    Color? green,
    Color? red,
    Color? interval,
    Color? paper,
    Color? onYellow,
    Color? logo,
    double? radius,
    double? radiusSm,
  }) {
    return FitroomTokens(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      stroke: stroke ?? this.stroke,
      yellow: yellow ?? this.yellow,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      blue: blue ?? this.blue,
      braun: braun ?? this.braun,
      violet: violet ?? this.violet,
      green: green ?? this.green,
      red: red ?? this.red,
      interval: interval ?? this.interval,
      paper: paper ?? this.paper,
      onYellow: onYellow ?? this.onYellow,
      logo: logo ?? this.logo,
      radius: radius ?? this.radius,
      radiusSm: radiusSm ?? this.radiusSm,
    );
  }

  @override
  FitroomTokens lerp(ThemeExtension<FitroomTokens>? other, double t) {
    if (other is! FitroomTokens) {
      return this;
    }
    return FitroomTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      braun: Color.lerp(braun, other.braun, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      green: Color.lerp(green, other.green, t)!,
      red: Color.lerp(red, other.red, t)!,
      interval: Color.lerp(interval, other.interval, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      onYellow: Color.lerp(onYellow, other.onYellow, t)!,
      logo: Color.lerp(logo, other.logo, t)!,
      radius: radius + (other.radius - radius) * t,
      radiusSm: radiusSm + (other.radiusSm - radiusSm) * t,
    );
  }
}

ThemeData buildTheme(Brightness brightness) {
  final tokens = brightness == Brightness.dark ? FitroomTokens.dark() : FitroomTokens.light();
  final onInk = brightness == Brightness.dark ? const Color(0xFF1A1A1A) : const Color(0xFFF6FAFA);
  final scheme = ColorScheme(
    brightness: brightness,
    primary: tokens.yellow,
    onPrimary: const Color(0xFF1A1A1A),
    secondary: tokens.blue,
    onSecondary: const Color(0xFF1A1A1A),
    error: tokens.red,
    onError: const Color(0xFFF6FAFA),
    surface: tokens.canvas,
    onSurface: tokens.ink,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: tokens.canvas,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: [tokens],
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.canvas,
      foregroundColor: tokens.ink,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: tokens.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius),
        side: BorderSide(color: tokens.stroke),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tokens.surface,
      indicatorColor: tokens.yellow.withValues(alpha: 0.24),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? tokens.yellow : tokens.ink,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.yellow,
        foregroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radius)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(tokens.radius)),
    ),
    dividerColor: tokens.stroke,
    textTheme: ThemeData(brightness: brightness).textTheme.apply(
          bodyColor: tokens.ink,
          displayColor: tokens.ink,
        ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? onInk : tokens.ink;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? tokens.yellow : tokens.stroke;
      }),
    ),
  );
}

/// Maps Figma canvas ink `#F6FAFA` to [FitroomTokens.ink] so glyphs stay
/// visible in both light and dark themes. Yellow plates stay `#FECE00`.
class _FigmaInkMapper extends ColorMapper {
  const _FigmaInkMapper(this.ink);

  final Color ink;

  static const _figmaInk = Color(0xFFF6FAFA);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == _figmaInk) {
      return ink;
    }
    return color;
  }
}

class FigmaIcon extends StatelessWidget {
  const FigmaIcon(this.asset, {super.key, this.size = 48});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorMapper: _FigmaInkMapper(FitroomTokens.of(context).ink),
    );
  }
}
