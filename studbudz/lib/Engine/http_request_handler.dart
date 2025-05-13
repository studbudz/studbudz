import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:studubdz/Engine/auth_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<Map<String, dynamic>> fetchData(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    print("Fetching data");

    // Check if the token exists
    final token = await _authManager.getToken();
    if (token.isEmpty) {
      throw Exception('Token not found or is empty');
    }

    final uri = Uri.parse('$_address/$endpoint');
    final url = queryParams != null && queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    try {
      final request = await _httpClient.getUrl(url);
      request.headers.set('Authorization', 'Bearer $token');
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data: $e");
      rethrow;
    }
  }

  Future<XFile> saveMedia(String endpoint) async {
    // 1) Build URI & get token
    final uri = Uri.parse('$_address/$endpoint');
    final token = await _authManager.getToken();

    // 2) Prepare a safe base name (slashes → underscores)
    final baseName = 'media_${endpoint.replaceAll('/', '_')}';

    // 3) Try to grab an extension from the URL path
    var ext = p.extension(uri.path);

    // 4) Prepare temp directory
    final dir = await getTemporaryDirectory();

    // 5) If we already know ext, check cache first
    if (ext.isNotEmpty) {
      final cachedPath = p.join(dir.path, '$baseName$ext');
      final cachedFile = File(cachedPath);
      if (await cachedFile.exists()) {
        print('Returning cached file: $cachedPath');
        return XFile(cachedPath, name: '$baseName$ext');
      }
    }

    // 6) Download the bytes (only now)
    final resp = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to download media: ${resp.statusCode}');
    }

    // 7) If we didn’t know the ext, derive it from content-type
    if (ext.isEmpty) {
      final ct = resp.headers['content-type'];
      if (ct != null && ct.contains('/')) {
        ext = '.${ct.split('/').last}';
      }
    }

    // 8) Final filename & write to disk
    final finalName = '$baseName$ext';
    final finalPath = p.join(dir.path, finalName);
    await File(finalPath).writeAsBytes(resp.bodyBytes);

    print('Downloaded and saved: $finalPath');
    return XFile(finalPath, name: finalName);
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
          'Failed to sign in: ${response.statusCode}, $responseBody',
        );
      }
    } catch (e) {
      // Debugging: print out the error message
      print('Error during sign in: $e');
      throw Exception('Error during sign in: $e');
    }
  }

  //sign up request
  Future<bool> signUpRequest(
    String username,
    String password,
    String words,
  ) async {
    final url = Uri.parse('$_address/signup');
    try {
      final request = await _httpClient.postUrl(url);
      request.headers.contentType = ContentType.json;

      // Send the username and password in the body as JSON
      Map<String, dynamic> data = {
        'username': username,
        'password': password,
        'words': words,
      };
      request.add(utf8.encode(jsonEncode(data)));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to sign up: ${response.statusCode}, $responseBody',
        );
      }
    } catch (e) {
      print('Error during sign up: $e');
      throw Exception('Error during sign up: $e');
    }
  }

  // Request to /userexists with GET and username as a query parameter
  Future<bool> userExists(String username) async {
    final url = Uri.parse('$_address/userexists').replace(
      queryParameters: {'username': username},
    );
    try {
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['exists'] ?? false;
      } else {
        throw Exception(
          'Failed to check user existence: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error checking user existence: $e');
      throw Exception('Error checking user existence: $e');
    }
  }

  // Method to check if the connection to the server is valid
  Future<void> checkConnection() async {
    final url = Uri.parse(
      '$_address/ping',
    ); // Use a 'ping' endpoint or a health-check endpoint
    try {
      final request = await _httpClient.getUrl(url);
      final response = await request.close();

      if (response.statusCode == 202) {
        print("Connected.");
      } else {
        // Server is not responding as expected
        print(
          'Failed to reach the server. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Error in connection (e.g., no network, unreachable host)
      print('Error while checking connection: $e');
    }
  }
}
