import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthManager {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveAuthData(String token, String uuid) async {
    try {
      await _secureStorage.write(key: 'token', value: token);
      await _secureStorage.write(key: 'uuid', value: uuid);
    } catch (e) {
      throw Exception('Error saving authentication data: $e');
    }
  }

  // Method to retrieve the token from secure storage
  Future<String> getToken() async {
    try {
      final token = await _secureStorage.read(key: 'token');
      if (token == null || token.isEmpty) {
        //send user to sign in page.
        throw Exception('Token not found or is empty');
      }
      return token;
    } catch (e) {
      rethrow;
    }
  }

  // Method to retrieve the UUID from secure storage
  Future<String> getUuid() async {
    try {
      final uuid = await _secureStorage.read(key: 'uuid');
      if (uuid == null) {
        //needs to send user to sign in page.
        throw Exception('UUID not found');
      }
      return uuid;
    } catch (e) {
      rethrow;
    }
  }

  //relatively simple logged in check.
  Future<bool> isLoggedIn() async {
    try {
      final uuid = await _secureStorage.read(key: "uuid");
      final token = await _secureStorage.read(key: "token");
      if (uuid == null || token == null) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
