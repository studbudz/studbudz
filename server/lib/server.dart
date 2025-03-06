import 'dart:io';
import 'package:server/token_validation.dart';
import 'websocket_handler.dart';

class Server {
  late HttpServer _httpServer;
  late TokenHandler _tokenHandler;
  late WebsocketHandler _webSocketHandler;

  Server() {
    _tokenHandler = TokenHandler();
  }

  Future<void> start() async {
    // Load SSL certificate and key
    SecurityContext context =
        SecurityContext()
          ..useCertificateChain('certificate.pem')
          ..usePrivateKey('private_key.pem');

    // Allows connection from any device on the current network using HTTPS.
    _httpServer = await HttpServer.bindSecure(
      InternetAddress.anyIPv4,
      8080,
      context,
    );
    print('Server running on port 8080');

    // Handles incoming connections
    await for (HttpRequest request in _httpServer) {
      if (request.uri.path == '/signin') {
        //requires username and password + uuid if the user has one
        //if the user doesn't have a uuid then they get sent one.
      } else if (request.uri.path == '/signup') {
        //requires a username, password and 24 words.
        //returns failure if exists
        //returns pass if succeeded
      }

      //get token from request
      String? token = request.headers.value('Authorization')?.split(' ').last;
      if (token == null || !_tokenHandler.validateToken(token)) {
        request.response.statusCode = HttpStatus.unauthorized;
        await request.response.close();
        continue;
      }

      //may not be the right param names
      String username = _tokenHandler.getInfo(token)['username'];

      if (WebSocketTransformer.isUpgradeRequest(request)) {
        //upgrade the connection to a websocket
        WebSocket socket = await WebSocketTransformer.upgrade(request);
        _webSocketHandler.handleConnection(socket, username);
        print('Upgraded to websocket connection.');
      } else if (request.method == 'POST') {
        //send data to the server.
        //handle post requests
      } else if (request.method == 'GET') {
        //requests data from the server
        //handle get requests
      } else {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
      }
    }
  }
}
