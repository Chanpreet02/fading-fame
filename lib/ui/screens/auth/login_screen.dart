import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    bool ok = false;

    if (_isLogin) {
      ok = await auth.login(email: email, password: password);
    } else {
      final fullName = _nameCtrl.text.trim();
      final age = _ageCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(_ageCtrl.text.trim());

      ok = await auth.signUp(
        fullName: fullName,
        email: email,
        password: password,
        age: age,
      );
    }

    if (!mounted) return;

    if (ok) {
      // success → go to home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      final error = auth.error ?? 'Something went wrong';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isLoading = auth.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLogin ? 'Login' : 'Create account',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                          ),
                          validator: (v) {
                            if (!_isLogin &&
                                (v == null || v.trim().isEmpty)) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _ageCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Age (optional)',
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if (!v.contains('@')) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return 'At least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: Text(isLoading
                              ? 'Please wait...'
                              : (_isLogin ? 'Login' : 'Sign up')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Don\'t have an account? Sign up'
                              : 'Already have an account? Login',
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
