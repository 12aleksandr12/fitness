import 'package:fitness_app/core/api_error.dart';
import 'package:fitness_app/core/language_picker.dart';
import 'package:fitness_app/features/auth/application/auth_controller.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.token});

  final String? token;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _token;
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _localError;

  @override
  void initState() {
    super.initState();
    _token = TextEditingController(text: widget.token ?? '');
  }

  @override
  void dispose() {
    _token.dispose();
    _name.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _registerError(AppLocalizations l10n, Object? error) {
    if (_localError != null) {
      return _localError;
    }
    if (error == null) {
      return null;
    }
    switch (apiErrorCode(error)) {
      case 'INVALID_INVITE':
        return l10n.invalidInvite;
      case 'EMAIL_TAKEN':
        return l10n.emailTaken;
      default:
        return l10n.registerFailed;
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final token = _token.text.trim();
    final name = _name.text.trim();
    final password = _password.text;
    if (token.isEmpty || name.isEmpty) {
      setState(() => _localError = l10n.checkRegisterFields);
      return;
    }
    if (password.length < 8) {
      setState(() => _localError = l10n.passwordMinLength);
      return;
    }
    if (password != _confirm.text) {
      setState(() => _localError = l10n.passwordsMismatch);
      return;
    }
    setState(() => _localError = null);
    ref.read(authControllerProvider.notifier).register(token: token, name: name, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context);
    final errorText = _registerError(l10n, auth.error);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: LanguageButton(),
                ),
                Text(l10n.register, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(l10n.registerHint, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TextField(
                  controller: _token,
                  enabled: !auth.isLoading,
                  decoration: InputDecoration(labelText: l10n.inviteToken),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  enabled: !auth.isLoading,
                  decoration: InputDecoration(labelText: l10n.name),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  enabled: !auth.isLoading,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.password),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirm,
                  enabled: !auth.isLoading,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.confirmPassword),
                ),
                const SizedBox(height: 24),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(errorText, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.register),
                ),
                TextButton(
                  onPressed: auth.isLoading ? null : () => context.go('/login'),
                  child: Text(l10n.backToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
