import 'package:studubdz/Engine/auth_manager.dart';
import 'package:studubdz/notifier.dart';
import 'http_request_handler.dart';

class Engine {
  final AuthManager _authManager = AuthManager(); //handles token and uuid
  late final Controller _controller; //
  late final WebsocketHandler;
  late final HttpRequestHandler _httpHandler;

  // Constructor ensures HttpRequestHandler is initialized upon Engine instantiation
  Engine() {
    //use websocket to connect instantly
    
    _httpHandler = HttpRequestHandler(
        address: 'https://192.168.1.107:8080', authManager: _authManager);
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
