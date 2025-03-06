import 'dart:convert';
import 'dart:io';

class WebsocketHandler {
  final Map<String, WebSocket> clients = {};

  void handleConnection(WebSocket socket, String username) {
    clients[username] = socket;
    socket.add(jsonEncode({'type': 'welcome'}));

    socket.listen(
      (message) {
        // print('Received message: $message');
        var data = jsonDecode(message);
        switch (data['type']) {
          case 'signal':
            _forward(data, username, 'signal');
            break;
          case 'offer':
            _forward(data, username, 'offer');
            break;
          case 'answer':
            _forward(data, username, 'answer');
            break;
          case 'ice_candidate':
            _forward(data, username, 'ice_candidate');
            break;
          default:
            print('Unknown message type: ${data['type']}');
        }
      },
      onDone: () {
        clients.remove(username);
        print('Client disconnected: $username');
      },
    );
  }

  void _forward(data, String clientId, String type) {
    String target = data['target'];
    if (clients.containsKey(target)) {
      clients[target]!.add(
        jsonEncode({'type': type, 'from': clientId, 'data': data['data']}),
      );
    }
  }
}
