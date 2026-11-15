final class AuthLoginResult {
  const AuthLoginResult({
    required this.userId,
    required this.accessToken,
  });

  final String userId;
  final String accessToken;
}

abstract interface class AuthApiClient {
  Future<AuthLoginResult> login(String email, String password);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String susCard,
  });

  Future<void> logout(String accessToken);
}
