import 'package:fitness_app/core/permissions.dart';
import 'package:fitness_app/core/require_permission.dart';
import 'package:fitness_app/features/schedule/application/schedule_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Клиенты')),
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
                title: Text(user['name'] as String),
                subtitle: Text('${user['email']} · ${role?['name'] ?? ''}'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ClientDetailScreen(userId: user['id'] as String, name: user['name'] as String),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.userId, required this.name});
  final String userId;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder(
        future: ref.read(studioRepositoryProvider).userPasses(userId),
        builder: (context, snapshot) {
          final passes = snapshot.data ?? [];
          final visits = passes.fold<int>(0, (s, p) => s + (p['remainingVisits'] as int? ?? 0));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Остаток: $visits'),
              RequirePermission(
                slug: Permissions.adjustBalance,
                child: FilledButton(
                  onPressed: () async {
                    await ref.read(studioRepositoryProvider).adjust(userId, 8, 'Начисление');
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Начислить 8 визитов'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
