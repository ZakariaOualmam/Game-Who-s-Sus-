import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mock_exceptions/src/mock_exceptions.dart' as mock_exceptions;
import 'package:wordimposter/services/firebase_auth_service.dart';

MockFirebaseAuth _authFor(String uid) {
  return MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: uid, isAnonymous: true),
  );
}

void main() {
  setUp(() {
    mock_exceptions.expectations.clear();
  });

  group('FirebaseAuthService', () {
    test('requireUid returns the existing signed-in user uid', () async {
      final auth = _authFor('alice');
      final service = FirebaseAuthService.forTesting(auth);

      expect(service.isAuthenticated, isTrue);
      expect(service.currentUid, 'alice');
      expect(await service.requireUid(), 'alice');
    });

    test('ensureAnonymousSignIn reuses the existing user', () async {
      final auth = _authFor('alice');
      final service = FirebaseAuthService.forTesting(auth);

      final before = auth.currentUser;
      final user = await service.ensureAnonymousSignIn();

      expect(user, same(before), reason: 'Must not create a second user');
      expect(auth.currentUser?.uid, 'alice');
    });

    test('ensureAnonymousSignIn creates a user when signed out', () async {
      final auth = MockFirebaseAuth();
      final service = FirebaseAuthService.forTesting(auth);

      expect(service.isAuthenticated, isFalse);

      final user = await service.ensureAnonymousSignIn();

      expect(user, isNotNull);
      expect(user!.isAnonymous, isTrue);
      expect(service.currentUid, user.uid);
    });

    test('requireUid throws when authentication fails', () async {
      final auth = MockFirebaseAuth();
      final service = FirebaseAuthService.forTesting(auth);

      whenCalling(Invocation.method(#signInAnonymously, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'network-error'));

      await expectLater(service.requireUid(), throwsA(isA<Exception>()));
    });
  });
}
