import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/app_user.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';

class ManageAdminsScreen extends StatelessWidget {
  const ManageAdminsScreen({super.key});

  void _changeRole(
      BuildContext context,
      AppUser user,
      String newRole,
      ) async {
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
    final auth = context.watch<AuthProvider>();

    final currentUserId = auth.user?.id;

    // Hide your own account
    final userList =
    admin.users.where((u) => u.id != currentUserId).toList();

    return ListView.builder(
      itemCount: userList.length,
      itemBuilder: (context, index) {
        final user = userList[index];
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
