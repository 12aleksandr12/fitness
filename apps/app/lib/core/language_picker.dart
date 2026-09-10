import 'package:fitness_app/core/app_languages.dart';
import 'package:fitness_app/core/locale_controller.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key, this.iconOnly = false});

  final bool iconOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (iconOnly) {
      return IconButton(
        tooltip: l10n.language,
        onPressed: () => showLanguagePicker(context, ref),
        icon: const Icon(Icons.language),
      );
    }
    return TextButton.icon(
      onPressed: () => showLanguagePicker(context, ref),
      icon: const Icon(Icons.language),
      label: Text(l10n.language),
    );
  }
}

Future<void> showLanguagePicker(BuildContext context, WidgetRef ref) async {
  final current = ref.read(localeControllerProvider).valueOrNull ?? const Locale('ru');
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.languageTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final lang in appLanguages)
            ListTile(
              title: Text(lang.nativeName),
              trailing: lang.code == current.languageCode ? const Icon(Icons.check) : null,
              onTap: () async {
                await ref.read(localeControllerProvider.notifier).setCode(lang.code);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              },
            ),
        ],
      ),
    ),
  );
}
