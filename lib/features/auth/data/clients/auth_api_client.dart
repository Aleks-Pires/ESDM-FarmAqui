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
  Future<void> logout(String accessToken);
}
