import '../../domain/errors/auth_exception.dart';
import 'auth_api_client.dart';

final class DemoAuthApiClient implements AuthApiClient {
  static const demoEmail = 'aluno@farmaaqui.app';
  static const demoPassword = '123456';

  String? _registeredEmail;
  String? _registeredPassword;
  String? _registeredName;
  String? _activeToken;

  @override
  Future<AuthLoginResult> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final normalizedEmail = email.trim().toLowerCase();
    final isDemo =
        normalizedEmail == demoEmail && password == demoPassword;
    final isRegistered =
        normalizedEmail == _registeredEmail && password == _registeredPassword;

    if (!isDemo && !isRegistered) {
      throw const AuthException('E-mail ou senha inválidos.');
    }

    final token = 'farmaaqui-${DateTime.now().millisecondsSinceEpoch}';
    _activeToken = token;

    return AuthLoginResult(
      userId: isRegistered
          ? (_registeredName ?? 'usuario-cadastrado')
          : 'demo-email-user',
      accessToken: token,
    );
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String susCard,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.length < 6) {
      throw const AuthException('Dados de cadastro inválidos.');
    }

    _registeredName = name.trim();
    _registeredEmail = normalizedEmail;
    _registeredPassword = password;
  }

  @override
  Future<void> logout(String accessToken) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (_activeToken == accessToken) {
      _activeToken = null;
    }
  }
}
