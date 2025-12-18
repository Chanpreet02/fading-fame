import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _changePassword(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            child: const Text('Update'),
            onPressed: () async {
              if (newCtrl.text.length < 6) {
                _snack(context, 'Password must be 6+ characters');
                return;
              }

              if (newCtrl.text != confirmCtrl.text) {
                _snack(context, 'Passwords do not match');
                return;
              }

              final auth = context.read<AuthProvider>();

              final ok = await auth.changePassword(
                oldPassword: oldCtrl.text.trim(),
                newPassword: newCtrl.text.trim(),
              );

              Navigator.pop(context);

              _snack(
                context,
                ok
                    ? 'Password changed successfully'
                    : (auth.error ?? 'Failed'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        child: Text(
                          (user?.fullName ?? 'U')
                              .split(' ')
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .take(2)
                              .join(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        user?.fullName ?? 'Anonymous',
                        style: AppTextStyles.h5,
                      ),
                      const SizedBox(height: 4),

                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.body2,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Role: ${user?.role ?? 'visitor'}',
                        style: AppTextStyles.body2,
                      ),
                      const SizedBox(height: 24),

                      // SizedBox(
                      //   width: double.infinity,
                      //   child: OutlinedButton.icon(
                      //     icon: const Icon(Icons.lock_outline),
                      //     label: const Text('Change password'),
                      //     onPressed: () async {
                      //       final auth = context.read<AuthProvider>();
                      //
                      //       final ok = await auth.sendPasswordReset(
                      //         auth.user!.email,
                      //       );
                      //
                      //       if (!context.mounted) return;
                      //
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           content: Text(
                      //             ok
                      //                 ? 'Password reset email sent to your email'
                      //                 : (auth.error ?? 'Something went wrong'),
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //   ),
                      // ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign out'),
                          onPressed: () {
                            auth.logout();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
