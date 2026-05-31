import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import 'auth_scaffold.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
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
          .signUp(_email.text.trim(), _password.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrazione avviata. Controlla la tua email.'),
          ),
        );
        context.go('/');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Crea il tuo account',
      subtitle: 'Inizia a monitorare e ribilanciare i tuoi investimenti',
      formKey: _formKey,
      emailController: _email,
      passwordController: _password,
      error: _error,
      loading: _loading,
      primaryLabel: 'Registrati',
      onSubmit: _submit,
      onGoogle: () =>
          ref.read(authControllerProvider.notifier).signInWithGoogle(),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Hai già un account?'),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Accedi'),
          ),
        ],
      ),
    );
  }
}
