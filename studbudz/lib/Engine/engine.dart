import 'package:image_picker/image_picker.dart';
import 'package:studubdz/Engine/auth_manager.dart';
import 'package:studubdz/notifier.dart';
import 'http_request_handler.dart';
import 'package:studubdz/config.dart';
import 'package:studubdz/Engine/websocket_handler.dart';

class Engine {
  late final AuthManager _authManager;
  late final Controller _controller;
  late WebsocketHandler _websocketHandler;
  late final HttpRequestHandler _httpHandler;
  late int userId = 0;

  Engine() {
    _authManager = AuthManager();
    _httpHandler = HttpRequestHandler(
        address: 'https://$address', authManager: _authManager);
    print('HttpHandler initialized: $_httpHandler');
    _websocketHandler = WebsocketHandler('ws://$address', _authManager);
  }

  void setController(Controller controller) {
    _controller = controller;
    print('Controller set: $_controller');
  }

  Future<bool> isLoggedIn() async {
    try {
      String token = await _authManager.getToken();
      return token.isNotEmpty; // Check if token exists and is valid
    } catch (e) {
      print("Error checking login state: $e");
      return false;
    }
  }

  Future<bool> logIn(String username, String password) async {
    print("Logging in with: $username and $password");

    try {
      bool response = await _httpHandler.signInRequest(username, password);
      if (response) {
        print("Login Success!");
        userId = int.parse(await getUserId()); // Initialize userId
        print("User ID initialized: $userId");
        return true;
      } else {
        print("Login failed.");
        return false;
      }
    } catch (e) {
      print("Login failed: $e");
      return false;
    }
  }

  //auto suggest for home page.
  Future<Map<dynamic, dynamic>> autoSuggest(String query) async {
    final response = await _httpHandler.fetchData('getUserSuggestionsFromName',
        queryParams: {'query': '$query%'});
    // print(response);
    return {"hi": "hi"};
  }

  Future<bool> createPost(dynamic data) async {
    bool success = false;

    String postType = data["type"];
    switch (postType) {
      case 'text':
        final response = await _httpHandler.sendData('textPost', data);
        if (response["success"] == true) {
          Controller().setPage(AppPage.feed);
        } else {
          //idk
        }
        break;
      // Both functions below require separate sendData Functions because they contain media
      case 'media':
        // print(data);
        final response = await _httpHandler.sendData('mediaPost', data);
        if (response["success"] == true) {
          Controller().setPage(AppPage.feed);
        } else {
          //idk
        }
        break;
      case 'event':
        // print(data);
        final response = await _httpHandler.sendData('eventPost', data);
        if (response["success"] == true) {
          Controller().setPage(AppPage.feed);
        } else {
          //idk
        }
        break;
      default:
        print('Unknown post type');
    }
    return success;
  }

  Future<dynamic> getFeed({required int page}) async {
    final params = {'page': '$page'};

    //makes the http request only
    final response = await _httpHandler.fetchData('feed', queryParams: params);
    // print("response: $response");
    return response;
  }

  Future<dynamic> getUserProfile({required int userID}) async {
    final params = {'user_id': '$userID'};

    // Call fetchData with the 'profile' endpoint and pass query params
    try {
      final response =
          await _httpHandler.fetchData('profile', queryParams: params);

      // Assuming the response is a map with profile data
      // print('User profile data: $response');
      return response;
    } catch (e) {
      // Handle the error if the request fails
      print('Error fetching profile data: $e');
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<XFile> downloadMedia({required endpoint}) async {
    print("downloading at ");
    final file = await _httpHandler.saveMedia(endpoint);
    print("downloaded");
    return file;
  }

  void logOut() {
    _authManager.logOut();
  }

  Future<void> followUser(userId) async {
    final response = await _httpHandler.sendData('follow', {'userID': userId});
  }

  Future<void> unfollowUser(userId) async {
    final response =
        await _httpHandler.sendData('unfollow', {'userID': userId});
  }

  Future<String> getUserId() async {
    return _authManager.getUserId();
  }

  Future<dynamic> getSubjects() async {
    return _httpHandler.fetchData('subjects');
  }

  Future<dynamic> getParticipantsCount({required int eventID}) async {
    final params = {'event_id': '$eventID'}; // Creating query params

    try {
      // Correctly calling fetchData with query parameters
      final response = await _httpHandler.fetchData('getparticipantscount',
          queryParams: params);

      return response;
    } catch (e) {
      // Handle errors if the request fails
      print('Error fetching participant count: $e');
      throw Exception('Failed to fetch participant count');
    }
  }

  Future<dynamic> getUpcomingEvents() async {
    try {
      // Correctly calling fetchData with query parameters
      final response = await _httpHandler.fetchData('getupcomingevents');
      return response;
    } catch (e) {
      // Handle errors if the request fails
      print('Error fetching events data: $e');
      throw Exception('Failed to fetch events data');
    }
  }

  Future<void> handleJoinEvent({required eventID}) async {
    final params = {'event_id': '$eventID'}; // Creating query params

    try {
      // Correctly calling fetchData with query parameters
      final response =
          await _httpHandler.sendData('joinevent', {'event_id': eventID});
    } catch (e) {
      // Handle errors if the request fails
      print('Error joining event: $e');
      throw Exception('Failed to join event');
    }
  }

  Future<void> hasJoinedEvent({required eventID}) async {
    final params = {'event_id': '$eventID'}; // Creating query params

    try {
      // Correctly calling fetchData with query parameters
      final response =
          await _httpHandler.fetchData('hasjoined', queryParams: params);
    } catch (e) {
      // Handle errors if the request fails
      print('Error checking event participation: $e');
      throw Exception('Failed to check event participation');
    }
  }

  Future<bool> userExists(String username) async {
    return _httpHandler.userExists(username);
  }

  Future<bool> signUpRequest(
      String username, String password, String words) async {
    print("Signing up with: $username and $password");
    return _httpHandler.signUpRequest(username, password, words);
  }
}
