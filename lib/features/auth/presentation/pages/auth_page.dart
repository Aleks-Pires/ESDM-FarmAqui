import 'package:flutter/material.dart';

import '../../../profile/presentation/pages/registration_page.dart';
import '../../data/clients/auth_api_client.dart';
import '../../domain/contracts/auth_strategy.dart';
import '../controllers/auth_controller.dart';
import '../widgets/authenticated_view.dart';
import '../widgets/login_form.dart';

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
    required this.authApi,
    super.key,
  });

  final AuthController controller;
  final EmailStrategyFactory emailStrategyFactory;
  final GoogleStrategyFactory googleStrategyFactory;
  final AuthApiClient authApi;

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

    await widget.controller.loginWith(
      widget.emailStrategyFactory(
        _emailController.text,
        _passwordController.text,
      ),
    );
  }

  Future<void> _loginWithGoogle() async {
    FocusScope.of(context).unfocus();
    widget.controller.clearError();

    final selected = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Escolha uma conta',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Continuar para o FarmaAqui com uma conta Google simulada.',
                ),
                const SizedBox(height: 18),
                _GoogleAccountTile(
                  name: 'Conta de demonstração',
                  email: 'usuario.demo@gmail.com',
                  initials: 'UD',
                  onTap: () => Navigator.pop(context, true),
                ),
                const Divider(),
                _GoogleAccountTile(
                  name: 'Usuário FarmaAqui',
                  email: 'farmaaqui.teste@gmail.com',
                  initials: 'FA',
                  onTap: () => Navigator.pop(context, true),
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_add_alt_1_rounded),
                  ),
                  title: const Text('Usar outra conta'),
                  subtitle: const Text('Simulação acadêmica'),
                  onTap: () => Navigator.pop(context, true),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != true) return;

    await widget.controller.loginWith(widget.googleStrategyFactory());
  }

  Future<void> _openRegistration() async {
    final credentials = await Navigator.of(context).push<RegisteredCredentials>(
      MaterialPageRoute(
        builder: (_) => RegistrationPage(authApi: widget.authApi),
      ),
    );

    if (credentials == null) return;

    _emailController.text = credentials.email;
    _passwordController.text = credentials.password;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conta criada. Agora é só entrar com os dados cadastrados.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (widget.controller.isAuthenticated) {
          return AuthenticatedView(controller: widget.controller);
        }

        return LoginForm(
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
          onCreateAccount: _openRegistration,
        );
      },
    );
  }
}


final class _GoogleAccountTile extends StatelessWidget {
  const _GoogleAccountTile({
    required this.name,
    required this.email,
    required this.initials,
    required this.onTap,
  });

  final String name;
  final String email;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE8F0FE),
        child: Text(
          initials,
          style: const TextStyle(
            color: Color(0xFF1967D2),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(email),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
