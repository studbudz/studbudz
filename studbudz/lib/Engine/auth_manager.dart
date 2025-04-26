import 'dart:convert';

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

  // Relatively simple logged in check.
  // Need to check if token is still valid. If not, delete both and log in.
  Future<bool> isLoggedIn() async {
    try {
      final uuid = await _secureStorage.read(key: "uuid");
      final token = await _secureStorage.read(key: "token");
      if (uuid == null || token == null) {
        return false;
      } else {
        // Add logic to validate the token here if necessary.
        // If token is invalid, clear storage and return false.
        final isTokenValid = await validateToken(token);
        if (!isTokenValid) {
          await _secureStorage.delete(key: "uuid");
          await _secureStorage.delete(key: "token");
          return false;
        }
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      // Decode the token (assuming it's a JWT)
      final parts = token.split('.');
      if (parts.length != 3) {
        return false; // Invalid token format
      }

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));

      // Parse the payload as JSON
      final payloadMap = json.decode(decodedPayload) as Map<String, dynamic>;

      // Check if the token has an expiration time
      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

        // Check if the token is expired
        if (DateTime.now().isAfter(expirationDate)) {
          return false; // Token is expired
        }
      }

      return true; // Token is valid
    } catch (e) {
      return false; // Error decoding or validating token
    }
  }
}
