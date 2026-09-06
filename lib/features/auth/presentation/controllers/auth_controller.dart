import 'package:flutter/foundation.dart';

import '../../domain/contracts/auth_strategy.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/errors/auth_exception.dart';

final class AuthController extends ChangeNotifier {
  AuthStrategy? _activeStrategy;

  AuthSession? session;
  bool loading = false;
  String? errorMessage;

  bool get isAuthenticated => session != null;

  Future<void> loginWith(AuthStrategy strategy) async {
    if (loading) return;

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _activeStrategy = strategy;
      session = await strategy.login();
    } on AuthException catch (error) {
      _activeStrategy = null;
      session = null;
      errorMessage = error.message;
    } catch (_) {
      _activeStrategy = null;
      session = null;
      errorMessage = 'Não foi possível entrar. Tente novamente.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (loading) return;

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _activeStrategy?.logout();
      _activeStrategy = null;
      session = null;
    } catch (_) {
      errorMessage = 'Não foi possível sair. Tente novamente.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }
}
