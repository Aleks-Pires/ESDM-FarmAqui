final class AuthSession {
  const AuthSession({
    required this.userId,
    required this.provider,
  });

  final String userId;
  final String provider;
}
