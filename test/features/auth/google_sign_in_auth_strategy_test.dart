import 'package:farma_aqui/features/auth/data/clients/google_auth_client.dart';
import 'package:farma_aqui/features/auth/data/strategies/google_sign_in_auth_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GoogleSignInAuthStrategy usa apenas o GoogleAuthClient', () async {
    final google = _FakeGoogleAuthClient();
    final strategy = GoogleSignInAuthStrategy(google);

    final session = await strategy.login();
    await strategy.logout();

    expect(session.userId, 'google-user');
    expect(session.provider, 'google');
    expect(google.signInCalled, isTrue);
    expect(google.signOutCalled, isTrue);
  });
}

final class _FakeGoogleAuthClient implements GoogleAuthClient {
  bool signInCalled = false;
  bool signOutCalled = false;

  @override
  Future<GoogleAccount> signIn() async {
    signInCalled = true;
    return const GoogleAccount(id: 'google-user');
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}
