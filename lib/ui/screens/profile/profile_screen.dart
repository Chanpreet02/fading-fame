import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: user == null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You are browsing as a visitor.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // login screen pe bhejna ho to:
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login / Sign up'),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(
                user.fullName.isNotEmpty
                    ? user.fullName[0].toUpperCase()
                    : user.email[0].toUpperCase(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(user.email),
            const SizedBox(height: 8),
            Text('Role: ${user.role}'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                      (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
