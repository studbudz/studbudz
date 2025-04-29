import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:server/sql_handler.dart';
import 'package:server/token_validation.dart';
import 'websocket_handler.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:http_server/http_server.dart';
import 'package:path/path.dart' as p;
import 'utils.dart';

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
    //certificate is self signed and is seen as extremely risky from the client side. (is encrypted and works for our purposes.)
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
      print("Received request: $request");
      if (request.uri.path == '/') {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..write('<h1>Hello, World!</h1>') // Response content
          ..close(); // Close the response
      }

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
        print("Connection refused.");
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
        print("Post Request: ${request.uri.path}");
        // Handle POST requests
        //create textPost-final data = {type, subject, post_content, post_private}

        final uri = request.uri.path;

        switch (uri) {
          case '/textPost':
            await _handleTextPost(request, username);
            break;
          case '/mediaPost':
            await _handleMediaPost(request, username);
            break;
          case '/eventPost':
            await _handleEventPost(request, username);
          default:
            request.response.statusCode = HttpStatus.notFound;
            await request.response.close();
        }
      } else if (request.method == 'GET') {
        // Handle GET requests
        final uri = request.uri.path;
        switch (uri) {
          case '/getUserSuggestionsFromName':
            break;
          case '/feed':
            await _handleGetFeed(request, username);
          default:
            Exception('not valid...');
        }
      } else {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
        print("Connection refused, other.");
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

  Future<Map<String, dynamic>> _parseJsonBody(HttpRequest request) async {
    final body = await utf8.decoder.bind(request).join();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<MultipartData> _parseMultipartBody(HttpRequest request) async {
    final body = await HttpBodyHandler.processRequest(request);
    if (body.body is! Map<String, dynamic>) {
      throw HttpException('Expected multipart/form-data');
    }
    final parts = body.body as Map<String, dynamic>;
    HttpBodyFileUpload? upload;
    final fields = <String, String>{};
    for (final entry in parts.entries) {
      final value = entry.value;
      if (value is HttpBodyFileUpload && upload == null) {
        upload = value;
      } else if (value is String) {
        fields[entry.key] = value;
      }
    }
    return MultipartData(fields: fields, file: upload);
  }

  // --- Helper database functions ---

  Future<int> _resolveUserId(String username) async {
    final rows = await _sqlHandler.select('getUserIdByUsername', [username]);
    if (rows.isEmpty) {
      throw HttpException('Unknown user');
    }
    return rows.first['user_id'] as int;
  }

  Future<int> _insertAndGetId(
    String insertQuery,
    List<dynamic> params,
    String lastIdQuery,
    String idKey,
  ) async {
    final count = await _sqlHandler.insert(insertQuery, params);
    if (count != 1) {
      throw HttpException('Insert failed');
    }
    final idRows = await _sqlHandler.select(lastIdQuery, []);
    return idRows.first[idKey] as int;
  }

  Future<void> _updateRecordUrl(String updateQuery, String url, int id) async {
    final count = await _sqlHandler.update(updateQuery, [url, id]);
    if (count != 1) {
      throw HttpException('URL update failed');
    }
  }

  // --- Helper file I/O function ---

  Future<String> _saveMediaFile(
    HttpBodyFileUpload upload,
    String directory, {
    String? filenameOverride,
  }) async {
    final original = upload.filename;
    final filename = filenameOverride ?? original;
    final dir = Directory(directory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final savePath = p.join(directory, filename);
    await File(savePath).writeAsBytes(upload.content as List<int>);
    return filename;
  }

  // --- Handlers ---

  Future<void> _handleTextPost(HttpRequest request, String username) async {
    try {
      final data = await _parseJsonBody(request);
      final userId = await _resolveUserId(username);
      final content = data['post_content'] as String;
      final isPrivate = data['post_private'] as bool;
      final postId = await _insertAndGetId(
        'createTextPost',
        [userId, content, isPrivate],
        'getLastInsertedPostId',
        'post_id',
      );
      request.response
        ..statusCode = HttpStatus.created
        ..write(jsonEncode({'success': true, 'post_id': postId}))
        ..close();
    } on HttpException catch (e) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write(e.message)
        ..close();
    }
  }

  Future<void> _handleMediaPost(HttpRequest request, String username) async {
    try {
      final multipart = await _parseMultipartBody(request);
      final upload = multipart.file;
      if (upload == null) throw HttpException('No media file provided');

      final userId = await _resolveUserId(username);
      final content = multipart.fields['post_content'] ?? '';
      final isPrivate =
          multipart.fields['post_private']?.toLowerCase() == 'true';
      final postId = await _insertAndGetId(
        'createTextPost',
        [userId, content, isPrivate],
        'getLastInsertedPostId',
        'post_id',
      );

      final ext = p.extension(upload.filename);
      final filename = await _saveMediaFile(
        upload,
        'assets/posts',
        filenameOverride: '$postId$ext',
      );
      final mediaUrl = 'posts/$filename';
      await _updateRecordUrl('updateMediaPost', mediaUrl, postId);

      request.response
        ..statusCode = HttpStatus.created
        ..write(
          jsonEncode({
            'success': true,
            'post_id': postId,
            'media_url': mediaUrl,
          }),
        )
        ..close();
    } on HttpException catch (e) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write(e.message)
        ..close();
    }
  }

  Future<void> _handleEventPost(HttpRequest request, String username) async {
    try {
      final multipart = await _parseMultipartBody(request);
      final userId = await _resolveUserId(username);

      final subjectId =
          multipart.fields['subject'] != null
              ? int.tryParse(multipart.fields['subject']!)
              : null;
      final eventName = multipart.fields['event_name']!;
      final eventDesc = multipart.fields['event_description']!;
      final eventLoc = multipart.fields['event_location_name']!;
      final startAt = multipart.fields['event_start_at']!;
      final endAt = multipart.fields['event_end_at']!;
      final isPrivate =
          multipart.fields['event_private']?.toLowerCase() == 'true';

      final eventId = await _insertAndGetId(
        'createEvent',
        [
          userId,
          subjectId,
          eventName,
          eventDesc,
          eventLoc,
          startAt,
          endAt,
          isPrivate,
        ],
        'getLastInsertedEventId',
        'event_id',
      );

      String? imageUrl;
      if (multipart.file != null) {
        final ext = p.extension(multipart.file!.filename);
        final filename = await _saveMediaFile(
          multipart.file!,
          'assets/events',
          filenameOverride: '$eventId$ext',
        );
        imageUrl = 'events/$filename';
        await _updateRecordUrl('updateEventImage', imageUrl, eventId);
      }

      request.response
        ..statusCode = HttpStatus.created
        ..write(
          jsonEncode({
            'success': true,
            'event_id': eventId,
            'event_image_url': imageUrl,
          }),
        )
        ..close();
    } on HttpException catch (e) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write(e.message)
        ..close();
    }
  }

  Future<void> _handleGetFeed(HttpRequest request, String username) async {
    print("Received request at /getfeed for user: $username");

    try {
      // Parse 'page' query parameter (default to 1 if not provided or invalid)
      final page =
          int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      final limit = 10;
      final offset = (page - 1) * limit;
      print("Parsed page: $page, limit: $limit, offset: $offset");

      // Get the user's ID
      final userRow = await _sqlHandler.select("getUserIdByUsername", [
        username,
      ]);
      if (userRow.isEmpty) throw HttpException('User not found');
      final userId = userRow.first['user_id'] as int;
      print("User ID resolved: $userId");

      // Fetch all data
      final followedPosts = await _sqlHandler.select(
        "getPostsByFollowedUsers",
        [userId, limit, offset],
      );
      final suggestedEvents = await _sqlHandler.select("getSuggestedEvents", [
        5,
      ]);
      final suggestedUsers = await _sqlHandler.select("getSuggestedUsers", [
        userId,
        5,
      ]);
      final newPosts = await _sqlHandler.select(
        "getNewPostsByNonFollowedUsers",
        [userId, 5, 0],
      );

      // === Handle DateTime conversion ===
      // Convert DateTime to ISO string for serialization
      void convertDateTime(Map<String, dynamic> data) {
        data.forEach((key, val) {
          if (val is DateTime) {
            data[key] = val.toIso8601String(); // Convert DateTime to ISO string
          }
        });
      }

      // Apply conversion to all data lists
      followedPosts.forEach(convertDateTime);
      suggestedEvents.forEach(convertDateTime);
      suggestedUsers.forEach(convertDateTime);
      newPosts.forEach(convertDateTime);

      // Combine data into response
      final response = {
        'followed_posts': followedPosts,
        'suggested_events': suggestedEvents,
        'suggested_users': suggestedUsers,
        'new_posts': newPosts,
      };

      // Send response
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(response));
      print("Response sent successfully");
    } catch (e) {
      print("Error occurred in _handleGetFeed: $e");
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error: $e');
    } finally {
      await request.response.close();
      print("Request processing completed for /getfeed");
    }
  }
}
