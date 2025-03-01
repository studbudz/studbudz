import 'dart:io';

///This is the server which performs:
///MUST IMPLEMENT RATE LIMITTING
///1. Accepts incoming connections
///2. upgrades the connection to a websocket
///3. forwards
///4. multi-casts messages to all connected clients
///5. respond to data requests

///Main function to start the serverq
void main() async {
  HttpServer server = await HttpServer.bind('0.0.0.0', 8080);
  print('WebSocket signaling server running on ws://localhost:8080');

  // Handles incoming connections
  await for (HttpRequest request in server) {
    //request to swap protocol to websocket
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

void denyConnection(HttpRequest request) {
  request.response.statusCode = HttpStatus.forbidden;
  request.response.close();
}
