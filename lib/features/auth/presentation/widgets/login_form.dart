import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';

final class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.controller,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.hidePassword,
    required this.onTogglePassword,
    required this.onLoginEmail,
    required this.onLoginGoogle,
    required this.onCreateAccount,
    super.key,
  });

  final AuthController controller;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool hidePassword;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onLoginEmail;
  final Future<void> Function() onLoginGoogle;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandHeader(),
                        const SizedBox(height: 28),
                        _EmailField(
                          controller: emailController,
                          enabled: !controller.loading,
                        ),
                        const SizedBox(height: 14),
                        _PasswordField(
                          controller: passwordController,
                          enabled: !controller.loading,
                          hidePassword: hidePassword,
                          onTogglePassword: onTogglePassword,
                          onSubmitted: onLoginEmail,
                        ),
                        if (controller.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          _ErrorMessage(message: controller.errorMessage!),
                        ],
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: controller.loading ? null : onLoginEmail,
                          icon: controller.loading
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.login_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            child: Text('Entrar'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _DividerWithText(),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: controller.loading ? null : onLoginGoogle,
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            child: Text('Entrar com Google'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: controller.loading ? null : onCreateAccount,
                          child: const Text('Criar conta'),
                        ),
                        const SizedBox(height: 12),
                        const _DemoNotice(),
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

final class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(
            Icons.local_pharmacy_rounded,
            size: 40,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'FarmaAqui',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F4C45),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Encontre o medicamento antes de se deslocar.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

final class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'E-mail',
        prefixIcon: Icon(Icons.mail_outline_rounded),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final email = value?.trim() ?? '';
        if (email.isEmpty) return 'Informe o e-mail.';
        if (!email.contains('@')) return 'Informe um e-mail válido.';
        return null;
      },
    );
  }
}

final class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.enabled,
    required this.hidePassword,
    required this.onTogglePassword,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool hidePassword;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: hidePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: onTogglePassword,
          tooltip: hidePassword ? 'Mostrar senha' : 'Ocultar senha',
          icon: Icon(
            hidePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
      validator: (value) {
        if ((value ?? '').isEmpty) return 'Informe a senha.';
        if ((value ?? '').length < 6) {
          return 'A senha deve ter pelo menos 6 caracteres.';
        }
        return null;
      },
    );
  }
}

final class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

final class _DividerWithText extends StatelessWidget {
  const _DividerWithText();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

final class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Credenciais de demonstração já preenchidas. '
        'O provedor Google é simulado neste protótipo acadêmico.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.5),
      ),
    );
  }
}
