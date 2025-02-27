import 'dart:io';

//basic server code
void main() async {
  HttpServer server = await HttpServer.bind('0.0.0.0', 8080);
  print('WebSocket signaling server running on ws://localhost:8080');

  // Handles incoming connections
  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      handleConnection(socket);
    } else {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
    }
  }
}

///Handles messages based on their type
///will send it to the appropriate module
void handleConnection(WebSocket socket) {
  socket.listen((message) {
    print('Message received: $message');
    socket.add(message);
  }, onDone: () {
    print('Client disconnected');
  });
}
