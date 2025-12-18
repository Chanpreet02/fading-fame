import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = Uri.base;

      if (uri.queryParameters['type'] == 'recovery') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.resetPassword,
        );
      }
    });
  }

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

    final auth = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();

    bool ok;

    if (_isLogin) {
      ok = await auth.login(email: email, password: password);
    } else {
      ok = await auth.signUp(
        fullName: _nameCtrl.text.trim(),
        email: email,
        password: password,
        age: _ageCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_ageCtrl.text.trim()),
      );
    }

    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Something went wrong')),
      );
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email first')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    final ok = await auth.sendPasswordReset(
      _emailCtrl.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Password reset email sent'
              : (auth.error ?? 'Something went wrong'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Fading Fame', style: AppTextStyles.h4),
                        const SizedBox(height: 8),

                        Text(
                          _isLogin
                              ? 'Welcome back'
                              : 'Create a new account',
                          style: AppTextStyles.body2,
                        ),
                        const SizedBox(height: 24),

                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                            validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
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
                            labelText: 'Email',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (!v.contains('@')) return 'Invalid email';
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
                          validator: (v) =>
                          v == null || v.length < 6
                              ? 'Min 6 characters'
                              : null,
                        ),

                        if (_isLogin)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed:
                              auth.isLoading ? null : _forgotPassword,
                              child: const Text('Forgot password?'),
                            ),
                          ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                            auth.isLoading ? null : _submit,
                            child: Text(
                              auth.isLoading
                                  ? 'Please wait...'
                                  : (_isLogin ? 'Login' : 'Sign up'),
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed: auth.isLoading
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
      ),
    );
  }
}
