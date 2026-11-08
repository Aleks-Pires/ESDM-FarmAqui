import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app/farma_aqui_app.dart';
import 'features/auth/data/clients/demo_auth_api_client.dart';
import 'features/auth/data/clients/demo_google_auth_client.dart';
import 'features/auth/data/clients/flutter_secure_storage_client.dart';
import 'features/auth/data/token/secure_token_manager.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storageClient = FlutterSecureStorageClient(
    const FlutterSecureStorage(),
  );
  final tokenManager = SecureTokenManager(storageClient);
  final api = DemoAuthApiClient();
  final google = DemoGoogleAuthClient();
  final controller = AuthController();

  runApp(
    FarmaAquiApp(
      controller: controller,
      api: api,
      tokenManager: tokenManager,
      google: google,
    ),
  );
}
