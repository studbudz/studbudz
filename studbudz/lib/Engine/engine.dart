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
    return await _authManager.isLoggedIn();
  }

  Future<bool> logIn(String username, String password) async {
    print("Logging in with: $username and $password");

    try {
      bool response = await _httpHandler.signInRequest(username, password);
      if (response) {
        print("Login Success!");
        return true;
      } else {
        print("Login failed.");
        return false;
      }
    } catch (e) {
      print("Login failed.");
      return false;
    }
  }

  Future<Map<dynamic, dynamic>> autoSuggest(String query) async {
    final response = await _httpHandler.fetchData('getUserSuggestionsFromName',
        queryParams: {'query': '$query%'});
    print(response);
    return {"hi": "hi"};
  }
}
