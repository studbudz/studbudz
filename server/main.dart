import 'dart:io';
import 'logger.dart';

///This is the server which performs:
///MUST IMPLEMENT RATE LIMITTING
///1. Accepts incoming connections
///2. upgrades the connection to a websocket
///3. forwards
///4. multi-casts messages to all connected clients
///5. respond to data requests

///Main function to start the serverq
void main() async {
  setupLogger();
  HttpServer server = await HttpServer.bind('0.0.0.0', 8080);
  appLogger.info('WebSocket signaling server running on ws://localhost:8080');

  // Handles incoming connections
  await for (HttpRequest request in server) {
    //request to swap protocol to websocket
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      //upgrade the connection to a websocket
    } else if (request.method == 'POST') {
      //handle post requests
    } else if (request.method == 'GET') {
      //handle get requests
    } else {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
    }
  }
}
