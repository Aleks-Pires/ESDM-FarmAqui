import '../../domain/contracts/auth_strategy.dart';
import '../../domain/contracts/token_manager.dart';
import '../../domain/entities/auth_session.dart';
import '../clients/auth_api_client.dart';

final class EmailPasswordAuthStrategy implements AuthStrategy {
  EmailPasswordAuthStrategy({
    required this.api,
    required this.tokens,
    required this.email,
    required this.password,
  });

  final AuthApiClient api;
  final TokenManager tokens;
  final String email;
  final String password;

  @override
  Future<AuthSession> login() async {
    final result = await api.login(email, password);
    await tokens.save(result.accessToken);

    return AuthSession(
      userId: result.userId,
      provider: 'email',
    );
  }

  @override
  Future<void> logout() async {
    final token = await tokens.read();
    if (token != null) {
      await api.logout(token);
    }
    await tokens.clear();
  }
}
