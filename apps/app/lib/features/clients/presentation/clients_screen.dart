import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/core/require_permission.dart';
import 'package:fitness_app/core/user_avatar.dart';
import 'package:fitness_app/features/clients/presentation/invite_dialog.dart';
import 'package:fitness_app/features/users/application/users_providers.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: RequirePermission(
              slug: Permissions.manageUsers,
              child: IconButton(
                tooltip: l10n.inviteUser,
                onPressed: () => showInviteDialog(context, ref),
                icon: const Icon(Icons.person_add_outlined),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: ref.read(usersRepositoryProvider).list(),
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
          ),
        ],
      ),
    );
  }
}
