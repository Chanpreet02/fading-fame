import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_profile.dart';
import '../../../providers/admin_provider.dart';

class ManageAdminsScreen extends StatelessWidget {
  const ManageAdminsScreen({super.key});

  void _changeRole(
      BuildContext context, UserProfile user, String newRole) async {
    final admin = context.read<AdminProvider>();
    await admin.changeUserRole(user.id, newRole);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role updated to $newRole')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return ListView.builder(
      itemCount: admin.users.length,
      itemBuilder: (context, index) {
        final user = admin.users[index];
        return ListTile(
          title: Text(user.fullName ?? 'User'),
          subtitle: Text('Role: ${user.role}'),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _changeRole(context, user, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'visitor', child: Text('Visitor')),
              PopupMenuItem(value: 'coadmin', child: Text('Co-admin')),
              PopupMenuItem(value: 'admin', child: Text('Admin')),
            ],
          ),
        );
      },
    );
  }
}
