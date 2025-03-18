import 'package:studubdz/Engine/engine.dart';

import 'auth_manager.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketHandler {
  late final WebSocketChannel _channel;
  late final AuthManager _authManager;
  late final String _address;
  bool _connected = false;

  WebsocketHandler(String address, AuthManager authManager) {
    _authManager = authManager;
    _address = address;
  }

  //connect to server
  void connect() {
    // if (!_connected) {
    //   // Get the token from AuthManager (or elsewhere)
    //   getToken();
    //   // If the token is missing or invalid, handle the error (e.g., log out or prompt for re-login)
    //   if (token == null) {
    //     print('Error: No token found');
    //     return;
    //   }

    //   print("connecting");
    //   // Connect to the WebSocket with the token included as a query parameter
    //   _channel = WebSocketChannel.connect(Uri.parse('$_address?token=$token'));

    //   _channel.stream.listen((message) {
    //     _connected = true;
    //     _handleMessage(message);
    //   }, onDone: () {
    //     _connected = false;
    //     print('Connection closed');
    //   }, onError: (error) {
    //     _connected = false;
    //     print('Error: $error');
    //   });
    //   //connect to server via websocket.
    //   //also deal with sending webrtc stuff to peer_connection_handler.
    // }
  }

  void _handleMessage(message) {
    print('Received message: $message');
    //parse message and send to controller.
  }
}
