import 'package:farma_aqui/features/auth/data/clients/auth_api_client.dart';
import 'package:farma_aqui/features/auth/data/strategies/email_password_auth_strategy.dart';
import 'package:farma_aqui/features/auth/domain/contracts/token_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmailPasswordAuthStrategy', () {
    test('faz login pela API e salva o token', () async {
      final api = _FakeAuthApiClient();
      final tokens = _FakeTokenManager();
      final strategy = EmailPasswordAuthStrategy(
        api: api,
        tokens: tokens,
        email: 'teste@farmaaqui.app',
        password: '123456',
      );

      final session = await strategy.login();

      expect(api.lastEmail, 'teste@farmaaqui.app');
      expect(tokens.savedToken, 'access-token');
      expect(session.userId, 'user-email');
      expect(session.provider, 'email');
    });

    test('no logout usa o token da API e depois o remove', () async {
      final api = _FakeAuthApiClient();
      final tokens = _FakeTokenManager()..savedToken = 'access-token';
      final strategy = EmailPasswordAuthStrategy(
        api: api,
        tokens: tokens,
        email: 'teste@farmaaqui.app',
        password: '123456',
      );

      await strategy.logout();

      expect(api.logoutToken, 'access-token');
      expect(tokens.savedToken, isNull);
      expect(tokens.clearCalled, isTrue);
    });
  });
}

final class _FakeAuthApiClient implements AuthApiClient {
  String? lastEmail;
  String? logoutToken;

  @override
  Future<AuthLoginResult> login(String email, String password) async {
    lastEmail = email;
    return const AuthLoginResult(
      userId: 'user-email',
      accessToken: 'access-token',
    );
  }

  @override
  Future<void> logout(String accessToken) async {
    logoutToken = accessToken;
  }
}

final class _FakeTokenManager implements TokenManager {
  String? savedToken;
  bool clearCalled = false;

  @override
  Future<void> clear() async {
    clearCalled = true;
    savedToken = null;
  }

  @override
  Future<String?> read() async => savedToken;

  @override
  Future<void> save(String token) async {
    savedToken = token;
  }
}
