import 'package:fitness_app/core/app_languages.dart';
import 'package:fitness_app/core/locale_controller.dart';
import 'package:fitness_app/core/router.dart';
import 'package:fitness_app/core/theme.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    for (final lang in appLanguages) initializeDateFormatting(lang.code),
  ]);
  runApp(const ProviderScope(child: FitnessApp()));
}

class FitnessApp extends ConsumerWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider).valueOrNull ?? const Locale('ru');
    return MaterialApp.router(
      title: 'Fitness',
      theme: buildTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
