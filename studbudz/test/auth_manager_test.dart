import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studubdz/Engine/auth_manager.dart';
import 'dart:convert';

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                              Mock Classes                               ║
// ╚══════════════════════════════════════════════════════════════════════════╝

class MockStorage extends Mock implements FlutterSecureStorage {}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                        Helper Functions                                 ║
// ╚══════════════════════════════════════════════════════════════════════════╝

/// Helper function to create a fake JWT for testing
String _makeToken(Map<String, dynamic> payload) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payloadEnc = base64Url.encode(utf8.encode(json.encode(payload)));
  return '$header.$payloadEnc.signature';
}

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                              Main Test Suite                            ║
// ╚══════════════════════════════════════════════════════════════════════════╝

void main() {
  late MockStorage mockStorage;
  late AuthManager auth;

  setUp(() {
    // Initialize mock storage and AuthManager before each test
    mockStorage = MockStorage();
    auth = AuthManager(storage: mockStorage);
  });

  // ╔════════════════════════════════════════════════════════════════════════╗
  // ║                            AuthManager Tests                          ║
  // ╚════════════════════════════════════════════════════════════════════════╝
  group('AuthManager', () {
    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                          saveAuthData Tests                         ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    group('saveAuthData', () {
      test('writes token and uuid to secure storage', () async {
        when(() => mockStorage.write(key: 'token', value: 'abc123'))
            .thenAnswer((_) async {});
        when(() => mockStorage.write(key: 'uuid', value: 'uuid-xyz'))
            .thenAnswer((_) async {});

        await auth.saveAuthData('abc123', 'uuid-xyz');

        verify(() => mockStorage.write(key: 'token', value: 'abc123'))
            .called(1);
        verify(() => mockStorage.write(key: 'uuid', value: 'uuid-xyz'))
            .called(1);
      });
    });

    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                          getUserId Tests                            ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    group('getUserId', () {
      test('returns userID from storage', () async {
        when(() => mockStorage.read(key: 'userID'))
            .thenAnswer((_) async => '77');

        final result = await auth.getUserId();
        expect(result, '77');
      });

      test('throws if userID is null', () async {
        when(() => mockStorage.read(key: 'userID'))
            .thenAnswer((_) async => null);

        expect(() => auth.getUserId(), throwsException);
      });
    });

    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                          getUsername Tests                          ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    group('getUsername', () {
      test('returns username from decoded token', () async {
        final token = _makeToken({'username': 'testUser'});
        when(() => mockStorage.read(key: 'token'))
            .thenAnswer((_) async => token);

        final result = await auth.getUsername();
        expect(result, 'testUser');
      });

      test('throws if token missing username', () async {
        final token = _makeToken({});
        when(() => mockStorage.read(key: 'token'))
            .thenAnswer((_) async => token);

        expect(() => auth.getUsername(), throwsException);
      });
    });

    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                      getUserIdFromToken Tests                       ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    group('getUserIdFromToken', () {
      test('extracts user_id from token', () async {
        final token = _makeToken({'user_id': 42});
        when(() => mockStorage.read(key: 'token'))
            .thenAnswer((_) async => token);

        final result = await auth.getUserIdFromToken();
        expect(result, 42);
      });

      test('throws if user_id is missing', () async {
        final token = _makeToken({});
        when(() => mockStorage.read(key: 'token'))
            .thenAnswer((_) async => token);

        expect(() => auth.getUserIdFromToken(), throwsException);
      });
    });

    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                          getToken Tests                             ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    group('getToken', () {
      test('returns stored token', () async {
        when(() => mockStorage.read(key: 'token'))
            .thenAnswer((_) async => 'abc');

        final result = await auth.getToken();
        expect(result, 'abc');
      });

      test('throws if token missing or empty', () async {
        when(() => mockStorage.read(key: 'token')).thenAnswer((_) async => '');

        expect(() => auth.getToken(), throwsException);
      });
    });

    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                          getUuid Tests                              ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    group('getUuid', () {
      test('returns stored uuid', () async {
        // Should return the uuid value from storage
        when(() => mockStorage.read(key: 'uuid'))
            .thenAnswer((_) async => 'uid');

        final result = await auth.getUuid();
        expect(result, 'uid');
      });

      test('throws if uuid missing', () async {
        // Should throw if uuid is not found in storage
        when(() => mockStorage.read(key: 'uuid')).thenAnswer((_) async => null);

        expect(() => auth.getUuid(), throwsException);
      });
    });

    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                          isLoggedIn Tests                           ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    group('isLoggedIn', () {
      test('returns true if token exists and valid', () async {
        // Should return true if token is not expired and uuid exists
        final token = _makeToken(
            {'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1000});
        when(() => mockStorage.read(key: 'token'))
            .thenAnswer((_) async => token);
        when(() => mockStorage.read(key: 'uuid'))
            .thenAnswer((_) async => 'some-uuid');

        final result = await auth.isLoggedIn();
        expect(result, true);
      });

      test('returns false if token is expired', () async {
        // Should return false if token is expired
        final token = _makeToken(
            {'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 1000});
        when(() => mockStorage.read(key: 'token'))
            .thenAnswer((_) async => token);
        when(() => mockStorage.read(key: 'uuid'))
            .thenAnswer((_) async => 'some-uuid');

        final result = await auth.isLoggedIn();
        expect(result, false);
      });

      test('returns false if uuid or token missing', () async {
        // Should return false if either token or uuid is missing
        when(() => mockStorage.read(key: 'token'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.read(key: 'uuid')).thenAnswer((_) async => null);

        final result = await auth.isLoggedIn();
        expect(result, false);
      });
    });

    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                          logOut Tests                               ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    group('logOut', () {
      test('deletes token and uuid from storage', () async {
        when(() => mockStorage.delete(key: 'token')).thenAnswer((_) async {});
        when(() => mockStorage.delete(key: 'uuid')).thenAnswer((_) async {});

        await auth.logOut();

        verify(() => mockStorage.delete(key: 'token')).called(1);
        verify(() => mockStorage.delete(key: 'uuid')).called(1);
      });
    });
  });
}
