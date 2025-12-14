import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/user_profile.dart';

class ManageAdminsScreen extends StatelessWidget {
  const ManageAdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: admin.users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return UserRow(user: admin.users[index]);
      },
    );
  }
}


class UserRow extends StatelessWidget {
  final UserProfile user;

  const UserRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();
    final auth = context.watch<AuthProvider>();

    final isSelf = auth.user?.id == user.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// ---------------- LEFT : USER INFO ----------------
          Expanded(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  child: Icon(Icons.person, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.role,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Row(
            children: [
              DropdownButton<String>(
                value: user.role,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'visitor', child: Text('Visitor')),
                  DropdownMenuItem(value: 'coadmin', child: Text('Co-Admin')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: isSelf
                    ? null
                    : (value) {
                  if (value == null) return;
                  admin.changeUserRole(user.id, value);
                },
              ),

              const SizedBox(width: 8),

              if(!isSelf)IconButton(
                tooltip: 'Delete user',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: isSelf
                    ? null
                    : () => _confirmDelete(context, admin, user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context,
      AdminProvider admin,
      UserProfile user,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete user'),
        content: Text(
          'Are you sure you want to delete "${user.fullName ?? 'this user'}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await admin.deleteUser(user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}