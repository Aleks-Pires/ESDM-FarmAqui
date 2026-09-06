import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage_client.dart';

final class FlutterSecureStorageClient implements SecureStorageClient {
  FlutterSecureStorageClient(this.storage);

  final FlutterSecureStorage storage;

  @override
  Future<void> write(String key, String value) {
    return storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) {
    return storage.read(key: key);
  }

  @override
  Future<void> delete(String key) {
    return storage.delete(key: key);
  }
}
