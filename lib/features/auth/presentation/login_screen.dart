import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import 'auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(_email.text.trim(), _password.text);
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Bentornato',
      subtitle: 'Accedi per gestire il tuo portafoglio',
      formKey: _formKey,
      emailController: _email,
      passwordController: _password,
      error: _error,
      loading: _loading,
      primaryLabel: 'Accedi',
      onSubmit: _submit,
      // Google auth temporaneamente disabilitato: ripristina `onGoogle` per
      // riattivare il pulsante "Continua con Google".
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Non hai un account?'),
          TextButton(
            onPressed: () => context.go('/signup'),
            child: const Text('Registrati'),
          ),
        ],
      ),
    );
  }
}
