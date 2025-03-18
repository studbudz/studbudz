import 'package:studubdz/Engine/auth_manager.dart';
import 'package:studubdz/notifier.dart';
import 'http_request_handler.dart';
import 'package:studubdz/config.dart';
import 'package:studubdz/Engine/websocket_handler.dart';
import 'package:studubdz/config.dart';

class Engine {
  final AuthManager _authManager = AuthManager(); //handles token and uuid
  late final Controller _controller; //
  late final _websocketHandler;
  late final HttpRequestHandler _httpHandler;

  // Constructor ensures HttpRequestHandler is initialized upon Engine instantiation
  Engine() {
    //use websocket to connect instantly
    _websocketHandler = WebsocketHandler('wss://$address', _authManager);
    _httpHandler = HttpRequestHandler(
        address: 'https://$address', authManager: _authManager);
    print('HttpHandler initialized: $_httpHandler');
    //connect to the webserver.
  }

  bool isLoggedIn() {
    try {
      //token needs to be verified by server.
      _authManager.getToken();
      _authManager.getUuid();
      return true;
    } catch (e) {
      return false;
    }
  }

  void setController(Controller controller) {
    _controller = controller;
    print('Controller set: $_controller');
  }

  Future<bool> logIn(String username, String password) async {
    print("Logging in with: $username and $password");

    try {
      bool response = await _httpHandler.signInRequest(username, password);
      if (response) {
        print("Success!");
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
    //perform query on Names
    final response = await _httpHandler.fetchData('getUserSuggestionsFromName',
        queryParams: {'query': '$query%'});
    //perform query on subjects
    //perform query on places -> uses stadia maps
    print(response);
    return {"hi": "hi"};
  }
}
