import '../../domain/contracts/auth_strategy.dart';
import '../../domain/entities/auth_session.dart';
import '../clients/google_auth_client.dart';

final class GoogleSignInAuthStrategy implements AuthStrategy {
  GoogleSignInAuthStrategy(this.google);

  final GoogleAuthClient google;

  @override
  Future<AuthSession> login() async {
    final account = await google.signIn();

    return AuthSession(
      userId: account.id,
      provider: 'google',
    );
  }

  @override
  Future<void> logout() {
    return google.signOut();
  }
}
