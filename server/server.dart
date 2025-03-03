import 'dart:io';

Future<void> main() async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  //0.0.0.0 is broadcast address
  //to connect, use server machine IP address
  print('Server running on http://${server.address.address}:8080');

  await for (var request in server) {
    request.response
      ..write('Bonjour, monde!')
      ..close();
  }
}
