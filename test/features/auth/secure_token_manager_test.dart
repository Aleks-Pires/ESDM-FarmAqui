import 'package:farma_aqui/features/auth/data/clients/secure_storage_client.dart';
import 'package:farma_aqui/features/auth/data/token/secure_token_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SecureTokenManager encapsula o mecanismo de armazenamento', () async {
    final storage = _FakeSecureStorageClient();
    final manager = SecureTokenManager(storage);

    await manager.save('abc');
    expect(await manager.read(), 'abc');

    await manager.clear();
    expect(await manager.read(), isNull);
  });
}

final class _FakeSecureStorageClient implements SecureStorageClient {
  final Map<String, String> _values = {};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}
