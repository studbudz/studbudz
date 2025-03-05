import 'package:easy_dart_jwt/easy_dart_jwt.dart'; // Alan's library
import 'package:uuid/uuid.dart';

class TokenHandler {
  late JWT jwt;

  TokenHandler() {
    jwt = JWT('private_key.pem', 'public_key.pem');
  }

  String requestToken(String username, {String? uuid}) {
    if (uuid == null || uuid.isEmpty) {
      var uuidGenerator = Uuid();
      uuidGenerator.v4();
    }

    final payload = {
      'username': username,
      'uuid': uuid,
      'iat':
          DateTime.now().millisecondsSinceEpoch ~/
          1000, // Current time in seconds
      'exp':
          DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000, // Expiration in 1 hour
    };

    return jwt.createToken(payload);
  }
}
