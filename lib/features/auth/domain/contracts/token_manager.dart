abstract interface class TokenManager {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> clear();
}
