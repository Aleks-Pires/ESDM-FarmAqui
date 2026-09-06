import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';

final class AuthenticatedView extends StatelessWidget {
  const AuthenticatedView({required this.controller, super.key});

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
