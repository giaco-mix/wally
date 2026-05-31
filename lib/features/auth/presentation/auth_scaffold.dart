import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';

/// Layout condiviso per login e registrazione.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.primaryLabel,
    required this.onSubmit,
    required this.footer,
    this.onGoogle,
    this.error,
    this.loading = false,
  });

  final String title;
  final String subtitle;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String primaryLabel;
  final VoidCallback onSubmit;
  final Widget footer;
  final VoidCallback? onGoogle;
  final String? error;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _WallyWordmark(),
                  const SizedBox(height: 24),
                  Text(title, style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Email non valida' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    onFieldSubmitted: (_) => onSubmit(),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Minimo 6 caratteri' : null,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: loading ? null : onSubmit,
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(primaryLabel),
                  ),
                  if (onGoogle != null && AppConfig.isConfigured) ...[
                    const SizedBox(height: 16),
                    const _OrDivider(),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: loading ? null : onGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Continua con Google'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  footer,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wordmark del brand: icona + "Wally".
class _WallyWordmark extends StatelessWidget {
  const _WallyWordmark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.savings, size: 36, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(height: 12),
        Text(
          'Wally',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: scheme.primary,
              ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('oppure',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
