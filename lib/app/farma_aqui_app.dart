import 'package:flutter/material.dart';

import '../features/auth/data/clients/auth_api_client.dart';
import '../features/auth/data/clients/google_auth_client.dart';
import '../features/auth/data/strategies/email_password_auth_strategy.dart';
import '../features/auth/data/strategies/google_sign_in_auth_strategy.dart';
import '../features/auth/domain/contracts/auth_strategy.dart';
import '../features/auth/domain/contracts/token_manager.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/auth_page.dart';

final class FarmaAquiApp extends StatelessWidget {
  const FarmaAquiApp({
    required this.controller,
    required this.api,
    required this.tokenManager,
    required this.google,
    super.key,
  });

  final AuthController controller;
  final AuthApiClient api;
  final TokenManager tokenManager;
  final GoogleAuthClient google;

  AuthStrategy _emailFactory(String email, String password) {
    return EmailPasswordAuthStrategy(
      api: api,
      tokens: tokenManager,
      email: email,
      password: password,
    );
  }

  AuthStrategy _googleFactory() {
    return GoogleSignInAuthStrategy(google);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmaAqui',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF157A6E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF8FAF9),
        ),
      ),
      home: AuthPage(
        controller: controller,
        emailStrategyFactory: _emailFactory,
        googleStrategyFactory: _googleFactory,
      ),
    );
  }
}
