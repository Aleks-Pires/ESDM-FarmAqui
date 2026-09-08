import '../../domain/contracts/token_manager.dart';
import '../clients/secure_storage_client.dart';

final class SecureTokenManager implements TokenManager {
  SecureTokenManager(this.storage);

  final SecureStorageClient storage;

  static const key = 'access_token';

  @override
  Future<void> save(String token) => storage.write(key, token);

  @override
  Future<String?> read() => storage.read(key);

  @override
  Future<void> clear() => storage.delete(key);
}
