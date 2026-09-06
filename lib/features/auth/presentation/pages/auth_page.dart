import 'package:flutter/material.dart';

import '../../domain/contracts/auth_strategy.dart';
import '../controllers/auth_controller.dart';

typedef EmailStrategyFactory = AuthStrategy Function(
  String email,
  String password,
);
typedef GoogleStrategyFactory = AuthStrategy Function();

final class AuthPage extends StatefulWidget {
  const AuthPage({
    required this.controller,
    required this.emailStrategyFactory,
    required this.googleStrategyFactory,
    super.key,
  });

  final AuthController controller;
  final EmailStrategyFactory emailStrategyFactory;
  final GoogleStrategyFactory googleStrategyFactory;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

final class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'aluno@farmaaqui.app';
    _passwordController.text = '123456';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    FocusScope.of(context).unfocus();
    widget.controller.clearError();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final strategy = widget.emailStrategyFactory(
      _emailController.text,
      _passwordController.text,
    );
    await widget.controller.loginWith(strategy);
  }

  Future<void> _loginWithGoogle() async {
    FocusScope.of(context).unfocus();
    widget.controller.clearError();
    await widget.controller.loginWith(widget.googleStrategyFactory());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (widget.controller.isAuthenticated) {
          return _AuthenticatedView(controller: widget.controller);
        }
        return _LoginView(
          controller: widget.controller,
          formKey: _formKey,
          emailController: _emailController,
          passwordController: _passwordController,
          hidePassword: _hidePassword,
          onTogglePassword: () {
            setState(() => _hidePassword = !_hidePassword);
          },
          onLoginEmail: _loginWithEmail,
          onLoginGoogle: _loginWithGoogle,
        );
      },
    );
  }
}

final class _LoginView extends StatelessWidget {
  const _LoginView({
    required this.controller,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.hidePassword,
    required this.onTogglePassword,
    required this.onLoginEmail,
    required this.onLoginGoogle,
  });

  final AuthController controller;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool hidePassword;
  final VoidCallback onTogglePassword;
  final Future<void> Function() onLoginEmail;
  final Future<void> Function() onLoginGoogle;

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
                        Align(
                          child: Container(
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
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: emailController,
                          enabled: !controller.loading,
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
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: passwordController,
                          enabled: !controller.loading,
                          obscureText: hidePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => onLoginEmail(),
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
                        ),
                        if (controller.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
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
                                    controller.errorMessage!,
                                    style: TextStyle(color: colors.onErrorContainer),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'ou',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: controller.loading ? null : onLoginGoogle,
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            child: Text('Entrar com Google'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
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

final class _AuthenticatedView extends StatelessWidget {
  const _AuthenticatedView({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = controller.session!;
    final providerLabel = session.provider == 'google' ? 'Google' : 'E-mail e senha';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('FarmaAqui'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      child: Icon(Icons.check_rounded, size: 38),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Autenticação concluída',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sessão iniciada por $providerLabel.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Usuário: ${session.userId}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: controller.loading ? null : controller.logout,
                        icon: controller.loading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.logout_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Sair'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
