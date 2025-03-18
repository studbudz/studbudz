import 'dart:convert';
import 'dart:io';
import 'package:server/sql_handler.dart';
import 'package:server/token_validation.dart';
import 'websocket_handler.dart';
import 'package:bcrypt/bcrypt.dart';

// Notifications -> websocket
// image/asset retrieval and post -> https
// signIn -> done ish
// chat -> websocket, webrtc
// coordinates -> idk

class Server {
  late HttpServer _httpServer;
  late TokenHandler _tokenHandler;
  late WebsocketHandler _webSocketHandler;
  late SqlHandler _sqlHandler;

  Server() {
    _tokenHandler = TokenHandler();
    _sqlHandler = SqlHandler();
  }

  Future<void> start() async {
    // Load SSL certificate and key
    //certificate is self signed and is seen as extremely risky. (is encrypted and works for our purposes.)
    SecurityContext context =
        SecurityContext()
          ..useCertificateChain('certificate.pem')
          ..usePrivateKey('private_key.pem');

    // Allows connection from any device on the current network using HTTPS.
    _httpServer = await HttpServer.bindSecure(
      InternetAddress.anyIPv4,
      8080,
      context,
    );
    print('Server running on port 8080');

    // Handles incoming connections
    await for (HttpRequest request in _httpServer) {
      print("Received request: ${request}");

      if (request.uri.path == '/signin') {
        print("Received Sign In request.");
        _handleSignIn(request);
        continue; // Prevent further processing of this request.
      } else if (request.uri.path == '/signup') {
        _handleSignUp(request);
        continue; // Prevent further processing.
      } else if (request.uri.path == '/ping') {
        request.response.statusCode = HttpStatus.accepted;
        await request.response.close();
        continue;
      }
      // Get token from request if the endpoint isn't sign in/up
      String? token = request.headers.value('Authorization')?.split(' ').last;
      if (token == null || !_tokenHandler.validateToken(token)) {
        request.response.statusCode = HttpStatus.unauthorized;
        await request.response.close();
        continue;
      }

      // Additional processing (e.g., WebSocket upgrade, POST/GET handling)
      String username = _tokenHandler.getInfo(token)['username'];
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        print('Upgrading to websocket connection.');
        WebSocket socket = await WebSocketTransformer.upgrade(request);
        _webSocketHandler.handleConnection(socket, token);
      } else if (request.method == 'POST') {
        // Handle POST requests
      } else if (request.method == 'GET') {
        // Handle GET requests
        final uri = request.uri.path;
        switch (uri) {
          case '/getUserSuggestionsFromName':
          default:
            Exception('not valid...');
        }
      } else {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
      }
    }
  }

  void _handleSignIn(HttpRequest request) async {
    try {
      // Read the request body
      String content = await utf8.decodeStream(request);
      Map<String, dynamic> requestBody = jsonDecode(content);

      String username = requestBody['username'];
      String password = requestBody['password'];

      //get salt and hashed password from sql_handler for that username
      //add and then return the password
      final data = await _sqlHandler.select("getUserCredentialsByUsername", [
        username,
      ]);

      print(data);
      String salt = data[0]['password_salt'];
      String passwordHash = data[0]['password_hash'];

      String concatenated = salt + password;

      String computedHash = BCrypt.hashpw(concatenated, passwordHash);

      // Validate the username and password (replace with actual validation logic)
      if (passwordHash == computedHash) {
        // Generate a token and UUID
        List<String?> values = _tokenHandler.requestToken(username);

        print(values);

        // Set headers before writing data
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({'token': values[0], 'uuid': values[1]}),
        );
      } else {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.headers.contentType = ContentType.text;
        request.response.write('Invalid credentials');
      }
    } catch (e) {
      print('Error handling sign-in: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.text;
      request.response.write('Internal server error');
    } finally {
      await request.response.close();
    }
  }

  void _handleSignUp(HttpRequest request) async {
    try {
      // For now, just send an OK response
      request.response.statusCode = HttpStatus.ok;
      request.response.write('Sign-up successful');
    } catch (e) {
      print('Error handling sign-up: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write('Internal server error');
    } finally {
      await request.response.close();
    }
  }

  Future<void> suggestion(HttpRequest request) async {
    final params = request.uri.queryParameters;
    final data = await _getNameSuggestions(params['query']!);

    request.response.headers.contentType = ContentType.json;
    request.response.statusCode = HttpStatus.ok;

    // Send the JSON encoded data as the response
    request.response.write(jsonEncode(data));

    await request.response.close();
  }

  Future<List<Map<String, dynamic>>> _getNameSuggestions(String query) async {
    final data = await _sqlHandler.select("getUserSuggestionsFromName", [
      query,
    ]);
    return data;
  }
}
