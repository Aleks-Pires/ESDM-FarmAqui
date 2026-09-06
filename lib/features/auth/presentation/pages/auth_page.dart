import 'package:flutter/material.dart';

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
    await widget.controller.loginWith(widget.googleStrategyFactory());
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
        );
      },
    );
  }
}
