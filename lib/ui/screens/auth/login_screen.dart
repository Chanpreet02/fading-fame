import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/app_loader.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _handlePostLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: AppLoader(message: 'Signing in...'),
      );
    }

    if (auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePostLogin(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fading Fame'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Welcome to Fading Fame',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Login with social media to explore viral stories, art and more.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (auth.error != null)
              Text(
                auth.error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => auth.signInWithGoogle(),
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => auth.signInWithFacebook(),
              icon: const Icon(Icons.facebook),
              label: const Text('Continue with Facebook'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
