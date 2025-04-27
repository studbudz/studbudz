import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/Engine/auth_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';

class HttpRequestHandler {
  late String _address;
  late AuthManager _authManager;
  late HttpClient _httpClient;
  late http.Client _client;

  HttpRequestHandler({
    required String address,
    required AuthManager authManager,
  }) {
    print("Initialised");

    _httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    _client = IOClient(_httpClient); // <<< this is the key change!

    _address = address;
    _authManager = authManager;

    checkConnection();
  }

  // Method to send data (POST request)
  //send arbitrary
  //return response
  Future<Map<String, dynamic>> sendData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    print("Sending data");
    final token = await _authManager.getToken();
    final uri = Uri.parse('$_address/$endpoint');

    // If there's at least one XFile in the map, do multipart/form-data
    if (data.values.any((v) => v is XFile)) {
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      // Populate fields & files
      for (final entry in data.entries) {
        if (entry.value is XFile) {
          final file = entry.value as XFile;
          String contentType = 'application/octet-stream'; // Default

          // Check for file type and adjust content type
          if (file.name.toLowerCase().endsWith('.mp4')) {
            contentType = 'video/mp4';
          } else if (file.name.toLowerCase().endsWith('.mp3')) {
            contentType = 'audio/mpeg';
          }

          req.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: file.name,
              contentType: MediaType.parse(contentType),
            ),
          );
        } else {
          req.fields[entry.key] = entry.value?.toString() ?? '';
        }
      }

      // **Use your IOClient** so the badCertificateCallback applies here:
      final streamed = await _client.send(req);
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return jsonDecode(resp.body);
      } else {
        throw Exception(
          'Failed to upload media: ${resp.statusCode} ${resp.body}',
        );
      }
    }

    // Otherwise: plain JSON POST
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to send data: ${response.statusCode} ${response.body}',
      );
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
