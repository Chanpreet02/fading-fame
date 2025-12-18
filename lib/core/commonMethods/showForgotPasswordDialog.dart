import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

void showForgotPasswordDialog(BuildContext context) {
  final emailCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Forgot password'),
      content: TextField(
        controller: emailCtrl,
        decoration: const InputDecoration(
          labelText: 'Email address',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          child: const Text('Send reset link'),
          onPressed: () async {
            final auth = context.read<AuthProvider>();
            final ok = await auth.sendPasswordReset(
              emailCtrl.text.trim().toLowerCase(),
            );

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ok
                      ? 'Password reset email sent'
                      : (auth.error ?? 'Error'),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
