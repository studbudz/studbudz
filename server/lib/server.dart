import 'dart:io';
import 'package:server/token_validation.dart';

class Server {
  late HttpServer _httpServer;
  late TokenHandler _tokenHandler;

  Server() {
    _tokenHandler = TokenHandler();
  }

  Future<void> start() async {
    // Load SSL certificate and key
    SecurityContext context =
        SecurityContext()
          ..useCertificateChain('path/to/your/certificate.pem')
          ..usePrivateKey('path/to/your/private_key.pem');

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
        //doesn't require a token.
        //may have a uuid? If the uuid
      } else if (request.uri.path == '/signup') {
        //requires
      }
      //else requires a token.

      //request to swap protocol to websocket
      //check for token first!!
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        //upgrade the connection to a websocket
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
