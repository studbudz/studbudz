import 'dart:convert';
import 'dart:io';

import 'package:studubdz/Engine/auth_manager.dart';

class HttpRequestHandler {
  late String _address;
  late AuthManager _authManager;
  final HttpClient _httpClient;

  HttpRequestHandler(
      {required String address, required AuthManager authManager})
      : _httpClient = HttpClient() {
    print("Initialised");

    _httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true; // Accept all certificates, including self-signed
    };
    _address = address;
    _authManager = authManager;
  }

  // Method to send data (POST request)
  Future<Map<String, dynamic>> sendData(
      String endpoint, Map<String, dynamic> data) async {
    //replace with get from auth manager
    final url = Uri.parse('$_address/$endpoint');
    try {
      final request = await _httpClient.postUrl(url);
      request.headers.contentType = ContentType.json;
      request.headers.set('Authorization',
          'Bearer ${_authManager.getToken()}'); // Add the token in the header
      request.add(utf8.encode(jsonEncode(data)));

      //send and close
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      //OK!
      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    //replace with getter from auth manager
    final url = Uri.parse('$_address/$endpoint');
    try {
      final request = await _httpClient.getUrl(url);
      request.headers.set('Authorization', 'Bearer ${_authManager.getToken()}');
      final response = await request.close();
      //into readable text
      //.join combines the multiple streams
      final responseBody = await response.transform(utf8.decoder).join();

      //OK!
      if (response.statusCode == 200) {
        // Decode the JSON response
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data $e');
    }
  }

  Future<bool> signInRequest(String username, String password) async {
    final url = Uri.parse('$_address/signin');
    try {
      final request = await _httpClient.postUrl(url);
      request.headers.contentType = ContentType.json;

      // Send the username and password in the body as JSON
      Map<String, dynamic> data = {'username': username, 'password': password};
      request.add(utf8.encode(jsonEncode(data)));

      final response = await request
          .close(); // both closing and sending the data to the server
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        // Assuming response contains 'token' and 'uuid'
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        print(jsonResponse);
        if (jsonResponse.containsKey('token') &&
            jsonResponse.containsKey('uuid')) {
          String token = jsonResponse['token'];
          String uuid = jsonResponse['uuid'];
          _authManager.saveAuthData(token, uuid);
          return true;
        } else {
          throw Exception('Invalid response structure: missing token or uuid');
        }
      } else {
        throw Exception(
            'Failed to sign in: ${response.statusCode}, $responseBody');
      }
    } catch (e) {
      // Debugging: print out the error message
      print('Error during sign in: $e');
      throw Exception('Error during sign in: $e');
    }
  }
}
