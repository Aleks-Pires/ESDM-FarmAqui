import '../entities/auth_session.dart';

abstract interface class AuthStrategy {
  Future<AuthSession> login();
  Future<void> logout();
}
