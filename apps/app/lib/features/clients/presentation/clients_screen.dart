import 'package:fitness_app/core/logout_button.dart';
import 'package:fitness_app/core/user_avatar.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).clients),
        actions: const [LogoutButton()],
      ),
      body: FutureBuilder(
        future: ref.read(studioRepositoryProvider).users(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final m = users[i];
              final user = m['user'] as Map<String, dynamic>;
              final role = m['role'] as Map<String, dynamic>?;
              return ListTile(
                leading: UserAvatar(
                  userId: user['id'] as String,
                  name: user['name'] as String? ?? '',
                  hasPhoto: user['hasPhoto'] == true,
                ),
                title: Text(user['name'] as String),
                subtitle: Text('${user['email'] ?? ''} · ${role?['name'] ?? ''}'),
                onTap: () => context.push('/people/${user['id']}'),
              );
            },
          );
        },
      ),
    );
  }
}
