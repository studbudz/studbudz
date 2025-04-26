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

    checkConnection();
  }

  // Method to send data (POST request)
  Future<Map<String, dynamic>> sendData(
      String endpoint, Map<String, dynamic> data) async {
    print("Sending data");
    final token = await _authManager.getToken();
    print(token);
    final url = Uri.parse('$_address/$endpoint');
    try {
      final request = await _httpClient.postUrl(url);
      request.headers.contentType = ContentType.json;
      request.headers
          .set('Authorization', 'Bearer $token'); // Set token in the header
      request.add(utf8.encode(jsonEncode(data)));

      //send and close
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      //OK!
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchData(String endpoint,
      {Map<String, String>? queryParams}) async {
    //replace with getter from auth manager
    final uri = Uri.parse('$_address/$endpoint');
    final url = queryParams != null && queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    print(url.queryParameters);

    try {
      final request = await _httpClient.getUrl(url);
      print("getting token3");
      final token = await _authManager.getToken();
      request.headers.set('Authorization', 'Bearer $token');
      final response = await request.close();
      print(response);
      //into readable text
      //.join combines the multiple streams
      final responseBody = await response.transform(utf8.decoder).join();

      //OK!
      if (response.statusCode == 200 || response.statusCode == 201) {
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

  // Method to check if the connection to the server is valid
  Future<void> checkConnection() async {
    final url = Uri.parse(
        '$_address/ping'); // Use a 'ping' endpoint or a health-check endpoint
    try {
      final request = await _httpClient.getUrl(url);
      final response = await request.close();

      if (response.statusCode == 202) {
        print("Connected.");
      } else {
        // Server is not responding as expected
        print(
            'Failed to reach the server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Error in connection (e.g., no network, unreachable host)
      print('Error while checking connection: $e');
    }
  }
}
