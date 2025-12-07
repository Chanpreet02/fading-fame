// lib/ui/screens/admin/manage_admins_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_profile.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';

class ManageAdminsScreen extends StatelessWidget {
  const ManageAdminsScreen({super.key});

  Future<void> _changeRole(
      BuildContext context,
      UserProfile user,      // ✅ yahan AppUser ki jagah UserProfile
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

    // jo custom login ka user hai (AppUser)
    final currentUserId = auth.user?.id;

    // apna khud ka account hide karne ke liye
    final List<UserProfile> userList = currentUserId == null
        ? admin.users
        : admin.users.where((u) => u.id != currentUserId).toList();

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
              PopupMenuItem(
                value: 'visitor',
                child: Text('Visitor'),
              ),
              PopupMenuItem(
                value: 'coadmin',
                child: Text('Co-admin'),
              ),
              PopupMenuItem(
                value: 'admin',
                child: Text('Admin'),
              ),
            ],
          ),
        );
      },
    );
  }
}
