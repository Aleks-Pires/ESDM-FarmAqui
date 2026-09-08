import 'package:farma_aqui/features/auth/domain/contracts/auth_strategy.dart';
import 'package:farma_aqui/features/auth/domain/entities/auth_session.dart';
import 'package:farma_aqui/features/auth/domain/errors/auth_exception.dart';
import 'package:farma_aqui/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthController', () {
    test('aceita qualquer AuthStrategy e guarda a sessão retornada', () async {
      final controller = AuthController();
      final strategy = _SuccessStrategy();

      await controller.loginWith(strategy);

      expect(controller.isAuthenticated, isTrue);
      expect(controller.session?.userId, 'user-1');
      expect(controller.session?.provider, 'fake');
      expect(controller.loading, isFalse);
      expect(controller.errorMessage, isNull);
    });

    test('limpa a sessão ao fazer logout', () async {
      final controller = AuthController();
      final strategy = _SuccessStrategy();

      await controller.loginWith(strategy);
      await controller.logout();

      expect(strategy.loggedOut, isTrue);
      expect(controller.session, isNull);
      expect(controller.isAuthenticated, isFalse);
    });

    test('expõe mensagem de erro sem depender de implementação concreta', () async {
      final controller = AuthController();

      await controller.loginWith(_FailStrategy());

      expect(controller.session, isNull);
      expect(controller.errorMessage, 'Credenciais inválidas.');
      expect(controller.loading, isFalse);
    });
  });
}

final class _SuccessStrategy implements AuthStrategy {
  bool loggedOut = false;

  @override
  Future<AuthSession> login() async {
    return const AuthSession(userId: 'user-1', provider: 'fake');
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
  }
}

final class _FailStrategy implements AuthStrategy {
  @override
  Future<AuthSession> login() async {
    throw const AuthException('Credenciais inválidas.');
  }

  @override
  Future<void> logout() async {}
}
