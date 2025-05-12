import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
    SecurityContext context =
        SecurityContext()
          ..useCertificateChain('certificate.pem')
          ..usePrivateKey('private_key.pem');

    _httpServer = await HttpServer.bindSecure(
      InternetAddress.anyIPv4,
      8080,
      context,
    );

    print('Server running on port 8080');

    await for (HttpRequest request in _httpServer) {
      print("Received request: ${request.uri.path}");

      // Public endpoints
      if (request.uri.path == '/signin') {
        _handleSignIn(request);
        continue;
      }
      if (request.uri.path == '/signup') {
        await _handleSignUp(request);
        continue;
      }
      if (request.uri.path == '/userexists') {
        await _handleUserExists(request);
        continue;
      }
      if (request.uri.path == '/ping') {
        request.response
          ..statusCode = HttpStatus.accepted
          ..close();
        continue;
      }

      // Authenticated endpoints
      String? token = request.headers.value('Authorization')?.split(' ').last;
      if (token == null || !_tokenHandler.validateToken(token)) {
        request.response
          ..statusCode = HttpStatus.unauthorized
          ..close();
        continue;
      }
      String username = _tokenHandler.getInfo(token)['username'];

      // WebSocket upgrade
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocket socket = await WebSocketTransformer.upgrade(request);
        _webSocketHandler.handleConnection(socket, token);
        continue;
      }

      if (request.method == 'POST') {
        switch (request.uri.path) {
          case '/textPost':
            await _handleTextPost(request, username);
            break;
          case '/mediaPost':
            await _handleMediaPost(request, username);
            break;
          case '/eventPost':
            await _handleEventPost(request, username);
            break;
          case '/follow':
            await _handleFollow(request, username);
            break;
          case '/unfollow':
            await _handleUnfollow(request, username);
            break;
          case '/joinevent':
            await _handleJoinEvent(request, username);
            break;
          default:
            request.response
              ..statusCode = HttpStatus.notFound
              ..close();
        }
        continue;
      }

      if (request.method == 'GET') {
        final uri = request.uri.path;
        if (uri.startsWith('/profiles/') ||
            uri.startsWith('/posts/') ||
            uri.startsWith('/events/')) {
          await _getMedia(request);
          continue;
        }
        if (uri == '/getUserSuggestionsFromName') {
          await suggestion(request);
          continue;
        }
        if (uri == '/feed') {
          await _handleGetFeed(request, username);
          continue;
        }
        if (uri == '/profile') {
          await _handleGetProfile(request, username);
          continue;
        }
        if (uri == '/subjects') {
          await _handleGetSubjects(request, username);
          continue;
        }
        if (uri == '/getparticipantscount') {
          await _handleGetParticipantCount(request, username);
          continue;
        }
        if (uri == '/getupcomingevents') {
          await _handleGetUpcomingEvents(request, username);
          continue;
        }
        if (uri == '/hasjoinedevent') {
          await _handleHasJoinedEvent(request, username);
          continue;
        }
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not Found')
          ..close();
        continue;
      }

      // Fallback for other methods
      request.response
        ..statusCode = HttpStatus.forbidden
        ..close();
    }
  }

  void _handleSignIn(HttpRequest request) async {
    try {
      String content = await utf8.decodeStream(request);
      Map<String, dynamic> body = jsonDecode(content);

      String username = body['username'];
      String password = body['password'];

      final data = await _sqlHandler.select("getUserCredentialsByUsername", [
        username,
      ]);
      String salt = data[0]['password_salt'];
      String hash = data[0]['password_hash'];
      String computed = BCrypt.hashpw(salt + password, hash);

      request.response.headers.contentType = ContentType.json;
      if (computed == hash) {
        List<String?> tokenData = _tokenHandler.requestToken(username);
        request.response
          ..statusCode = HttpStatus.ok
          ..write(
            jsonEncode({
              'token': tokenData[0],
              'uuid': tokenData[1],
              'user_id': data[0]['user_id'],
            }),
          );
      } else {
        request.response
          ..statusCode = HttpStatus.unauthorized
          ..write(jsonEncode({'error': 'Invalid credentials'}));
      }
    } catch (e) {
      print('SignIn error: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({'error': 'Internal server error'}));
    } finally {
      await request.response.close();
    }
  }

  Future<void> _handleUserExists(HttpRequest request) async {
    final username = request.uri.queryParameters['username'] ?? '';
    final data = await _sqlHandler.select("getUserIdByUsername", [username]);
    bool exists = data.isNotEmpty;

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'exists': exists}))
      ..close();
  }

  Future<void> _handleSignUp(HttpRequest request) async {
    print("Received sign-up request");

    String content = await utf8.decodeStream(request);
    Map<String, dynamic> body = jsonDecode(content);

    //we have useranem, password and words
    String username = body['username'];
    String password = body['password'];
    String words = body['words'];

    String passwordSalt = BCrypt.gensalt();
    String wordsSalt = BCrypt.gensalt();

    // Hashing algorithm is bcrypt
    // Password hash = password + salt
    // Words hash = salt + words
    String passwordHash = BCrypt.hashpw(
      passwordSalt + password,
      BCrypt.gensalt(),
    );
    String wordsHash = BCrypt.hashpw(wordsSalt + words, BCrypt.gensalt());

    print("Password Hash: $passwordHash");
    print("Words Hash: $wordsHash");

    await _sqlHandler.insert('createUser', [
      username,
      passwordSalt,
      passwordHash,
      wordsSalt,
      wordsHash,
    ]);

    try {
      // parse, hash, insert into DB...
      request.response
        ..statusCode = HttpStatus.ok
        ..write('Sign-up successful');
    } catch (e) {
      print('SignUp error: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Internal server error');
    } finally {
      await request.response.close();
    }
  }

  Future<void> suggestion(HttpRequest request) async {
    final q = request.uri.queryParameters['query'] ?? '';
    final data = await _getNameSuggestions(q);
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(data))
      ..close();
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

  Future<void> _handleTextPost(HttpRequest request, String username) async {
    try {
      final data = await _parseJsonBody(request);

      // print(data);
      // print(data);

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
      // final page =
      //     int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      // final limit = 10;
      // final offset = (page - 1) * limit;
      // print("Parsed page: $page, limit: $limit, offset: $offset");

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
        [userId],
      );
      final suggestedUsers = await _sqlHandler.select("getSuggestedUsers", [
        userId,
        userId,
      ]);
      // print("");
      // print("Suggested: ${suggestedUsers}");
      // print("");
      final newPosts = await _sqlHandler.select(
        "getNewPostsByNonFollowedUsers",
        [userId],
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
      suggestedUsers.forEach(convertDateTime);
      newPosts.forEach(convertDateTime);

      final data = formatPosts(followedPosts, suggestedUsers, newPosts);

      final output = {'posts': data};

      // Send response
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(output));
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

  formatPosts(
    List<Map<String, dynamic>> followedPosts,
    List<Map<String, dynamic>> suggestedUsers,
    List<Map<String, dynamic>> newPosts,
  ) {
    final output = [];

    for (var user in suggestedUsers) {
      user["type"] = "user";
    }

    output
      ..addAll(followedPosts)
      ..addAll(suggestedUsers)
      ..addAll(newPosts);

    //shuffle with fixed seed so that there are pages.
    output.shuffle(Random(42));

    // for (var item in output) {
    //   print(jsonEncode(item));
    // }

    return output;
  }

  Future<void> _getMedia(HttpRequest request) async {
    // Extract the requested URI from the request path
    final uri =
        request.uri.path.startsWith('/')
            ? request.uri.path.substring(1)
            : request.uri.path;

    // Ensure the path starts with "profiles/" and points to a valid file in the "assets/" folder
    if (uri.startsWith('profiles/') ||
        uri.startsWith('posts/') ||
        uri.startsWith('events/')) {
      final filePath = 'assets/$uri'; // Files stored in the "assets" folder
      print("path: $filePath");
      final file = File(filePath);

      // Check if the file exists
      if (await file.exists()) {
        final bytes = await file.readAsBytes(); // Read the file as bytes

        // print("done");
        // Respond with the file content
        request.response
          ..statusCode = HttpStatus.ok
          ..add(bytes)
          ..close();
      } else {
        // Return a 404 error if the file doesn't exist
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('File not found at $filePath')
          ..close();
      }
    } else {
      // Return a 400 error if the request path doesn't match the expected format
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Invalid media path: $uri')
        ..close();
    }
  }

  Future<void> _handleFollow(HttpRequest request, String username) async {
    String content = await utf8.decodeStream(request);
    Map<String, dynamic> requestBody = jsonDecode(content);

    final followingId = requestBody["userID"];

    final userRow = await _sqlHandler.select("getUserIdByUsername", [username]);
    if (userRow.isEmpty) throw HttpException('User not found');
    final followerId = userRow.first['user_id'] as int;

    final count = await _sqlHandler.insert('followUser', [
      followingId,
      followerId,
    ]);
    if (count != 1) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({'success': false, 'error': 'Insert failed'}))
        ..close();
      return;
    }
    request.response
      ..statusCode = HttpStatus.ok
      ..write(jsonEncode({'success': true}))
      ..close();
  }

  Future<void> _handleUnfollow(HttpRequest request, String username) async {
    String content = await utf8.decodeStream(request);
    Map<String, dynamic> requestBody = jsonDecode(content);

    final unfollowingId = requestBody["userID"];

    final userRow = await _sqlHandler.select("getUserIdByUsername", [username]);
    if (userRow.isEmpty) throw HttpException('User not found');
    final followerId = userRow.first['user_id'] as int;

    final count = await _sqlHandler.delete('unfollowUser', [
      unfollowingId,
      followerId,
    ]);
    if (count != 1) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({'success': false, 'error': 'Delete failed'}))
        ..close();
      return;
    }
    request.response
      ..statusCode = HttpStatus.ok
      ..write(jsonEncode({'success': true}))
      ..close();
  }

  Future<void> _handleGetProfile(HttpRequest request, String username) async {
    final userID = int.tryParse(request.uri.queryParameters['user_id'] ?? '');
    if (userID == null) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': 'Invalid or missing user_id'}))
        ..close();
      return;
    }

    try {
      final userRows = await _sqlHandler.select('getUserById', [
        userID,
        userID,
      ]);

      // print(userRows);

      if (userRows.isEmpty) {
        request.response
          ..statusCode = HttpStatus.notFound
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': 'User not found'}))
          ..close();
        return;
      }

      final posts = await _sqlHandler.select('getUserPosts', [userID]);

      // Convert DateTime objects to ISO 8601 string format
      var user = userRows.first;
      user['joined_at'] = (user['joined_at'] as DateTime).toIso8601String();
      // Convert DateTime objects for posts
      for (var post in posts) {
        final rawDate = post['post_created_at'];

        if (rawDate is DateTime) {
          post['post_created_at'] = rawDate.toIso8601String();
        } else if (rawDate is String) {
          // already a string, skip
        } else {
          post['post_created_at'] = null;
        }

        // Do the same for event dates, if they're present
        final startAt = post['event_start_at'];
        if (startAt is DateTime) {
          post['event_start_at'] = startAt.toIso8601String();
        }
        final endAt = post['event_end_at'];
        if (endAt is DateTime) {
          post['event_end_at'] = endAt.toIso8601String();
        }
      }

      // Directly return the raw values with DateTime converted to string
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'user': user, // Use the raw data with formatted DateTime
            'posts': posts, // Use the raw posts data with formatted DateTime
          }),
        )
        ..close();
    } catch (e) {
      print('[_handleGetProfile] ERROR: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': 'Server error'}))
        ..close();
    }
  }

  Future<void> _handleGetSubjects(HttpRequest request, String username) async {
    final userRows = await _sqlHandler.select('getAllSubjects', []);

    if (userRows.isEmpty) {
      request.response
        ..statusCode = HttpStatus.notFound
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': 'User not found'}))
        ..close();
      return;
    }
    // Directly return the raw values with DateTime converted to string
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(
        jsonEncode({
          'subjects': userRows, // Use the raw data with formatted DateTime
        }),
      )
      ..close();
  }

  Future<void> _handleJoinEvent(HttpRequest request, String username) async {
    try {
      String content = await utf8.decodeStream(request);
      Map<String, dynamic> requestBody = jsonDecode(content);

      print("Join Event Request: $requestBody");

      final eventID = requestBody['event_id'] as int;

      final userID = await _resolveUserId(username);

      final eventRows = await _sqlHandler.insert('addUserToEvent', [
        userID,
        eventID,
      ]);

      print(eventRows);

      if (eventRows != 1) {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': 'Failed to join event'}))
          ..close();
        return;
      }
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'success': true}))
        ..close();

      // Your existing logic for joining the event goes here
    } catch (e) {
      print("Error: $e");
      // Your existing logic for joining the event goes here
    } finally {
      await request.response.close();
    }
  }

  Future<void> _handleGetParticipantCount(
    HttpRequest request,
    String username,
  ) async {
    final eventID = int.tryParse(request.uri.queryParameters['event_id'] ?? '');

    if (eventID == null) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': 'Invalid or missing event_id'}))
        ..close();
      return;
    }

    try {
      final eventRows = await _sqlHandler.select('getParticipantsCount', [
        eventID,
      ]);

      if (eventRows.isEmpty) {
        request.response
          ..statusCode = HttpStatus.notFound
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': 'Event not found'}))
          ..close();
        return;
      }

      int participantCount = eventRows[0]['participants_count'];

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'participant_count': participantCount}))
        ..close();
    } catch (e) {
      // Catch and handle any errors that occurred
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error parsing request: $e')
        ..close();
    }
  }

  Future<void> _handleGetEventData(HttpRequest request, String username) async {
    final userId = await _resolveUserId(username);
    try {
      final eventRows = await _sqlHandler.select('getEventData', [userId]);

      if (eventRows.isEmpty) {
        request.response
          ..statusCode = HttpStatus.notFound
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': 'Event not found'}))
          ..close();
        return;
      }

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'event_data': eventRows}))
        ..close();
    } catch (e) {
      // Catch and handle any errors that occurred
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error parsing request: $e')
        ..close();
    }
  }

  Future<void> _handleGetUpcomingEvents(
    HttpRequest request,
    String username,
  ) async {
    final userId = await _resolveUserId(username);
    try {
      final rawRows = await _sqlHandler.select('getUpcomingEvents', [userId]);
      final List<Map<String, dynamic>> eventData =
          rawRows.map((row) {
            return {
              'userId': row['user_id'] as int,
              'subjectId': row['subject_id'] as int?,
              'eventName': row['event_name'] as String,
              'eventImage': row['event_image'] as String,
              'eventDescription': row['event_description'] as String,
              'eventLocationName': row['event_location_name'] as String,
              'eventAddress': row['event_address'] as String,
              'eventStartAt':
                  (row['event_start_at'] as DateTime).toIso8601String(),
              'eventEndAt': (row['event_end_at'] as DateTime).toIso8601String(),
            };
          }).toList();
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'event_data': eventData}))
        ..close();
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Error parsing request: $e')
        ..close();
    }
  }

  Future<void> _handleHasJoinedEvent(
    HttpRequest request,
    String username,
  ) async {
    final eventID = int.tryParse(request.uri.queryParameters['event_id'] ?? '');
    final userId = await _resolveUserId(username);
  }
}
