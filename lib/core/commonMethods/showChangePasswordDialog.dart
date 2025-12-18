import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

void showChangePasswordDialog(BuildContext context) {
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
          child: const Text('Continue'),
          onPressed: () async {
            if (newCtrl.text != confirmCtrl.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords do not match')),
              );
              return;
            }

            final auth = context.read<AuthProvider>();

            final ok = await auth.verifyPasswordAndSendReset(
              oldPassword: oldCtrl.text.trim(),
            );

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok
                      ? 'Password reset email sent'
                      : (auth.error ?? 'Invalid password'),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
