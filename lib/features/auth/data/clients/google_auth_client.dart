final class GoogleAccount {
  const GoogleAccount({required this.id});

  final String id;
}

abstract interface class GoogleAuthClient {
  Future<GoogleAccount> signIn();
  Future<void> signOut();
}
