import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthManager {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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
      if (token == null) {
        throw Exception('Token not found');
      }
      return token;
    } catch (e) {
      throw Exception('Error retrieving token: $e');
    }
  }

  // Method to retrieve the UUID from secure storage
  Future<String> getUuid() async {
    try {
      final uuid = await _secureStorage.read(key: 'uuid');
      if (uuid == null) {
        throw Exception('UUID not found');
      }
      return uuid;
    } catch (e) {
      throw Exception('Error retrieving UUID: $e');
    }
  }
}
