import 'dart:io';

class Server {
  late HttpServer _httpServer;

  Future<void> start() async {
    //allows connection from any device on the current network.
    _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
    print('Server running on port 8080');

    await for (HttpRequest request in _httpServer) {
      return;
    }
  }
}
