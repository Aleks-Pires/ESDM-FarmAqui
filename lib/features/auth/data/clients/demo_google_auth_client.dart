import 'google_auth_client.dart';

final class DemoGoogleAuthClient implements GoogleAuthClient {
  bool _signedIn = false;

  @override
  Future<GoogleAccount> signIn() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _signedIn = true;
    return const GoogleAccount(id: 'demo-google-user');
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _signedIn = false;
  }

  bool get isSignedIn => _signedIn;
}
