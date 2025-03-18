import 'auth_manager.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketHandler {
  late WebSocketChannel _channel;

  WebsocketHandler(String address, AuthManager authManager) {
    _channel = WebSocketChannel.connect(Uri.parse(address));

    _channel.stream.listen((message) => _handleMessage(message), onDone: () {
      print('Connection closed');
    }, onError: (error) {
      print('Error: $error');
    });
    //connect to server via websocket.
    //also deal with sending webrtc stuff to peer_cpmmection_handler.
  }

  void _handleMessage(message) {
    print('Received message: $message');
    //parse message and send to controller.
  }
}
