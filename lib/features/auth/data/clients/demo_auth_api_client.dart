import '../../domain/errors/auth_exception.dart';
import 'auth_api_client.dart';

final class DemoAuthApiClient implements AuthApiClient {
  static const demoEmail = 'aluno@farmaaqui.app';
  static const demoPassword = '123456';

  String? _activeToken;

  @override
  Future<AuthLoginResult> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != demoEmail || password != demoPassword) {
      throw const AuthException('E-mail ou senha inválidos.');
    }

    final token = 'farmaaqui-${DateTime.now().millisecondsSinceEpoch}';
    _activeToken = token;

    return AuthLoginResult(
      userId: 'demo-email-user',
      accessToken: token,
    );
  }

  @override
  Future<void> logout(String accessToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (_activeToken == accessToken) {
      _activeToken = null;
    }
  }
}
