import 'package:easy_dart_jwt/easy_dart_jwt.dart'; // Alan's library
import 'package:uuid/uuid.dart';

class TokenHandler {
  late JWT jwt;

  TokenHandler() {
    jwt = JWT('private_key.pem', 'public_key.pem');
  }

  List<String?> requestToken(String username, {String? uuid}) {
    if (uuid == null || uuid.isEmpty) {
      var uuidGenerator = Uuid();
      uuidGenerator.v4();
    }

    final payload = {
      'username': username,
      'uuid': uuid,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          DateTime.now().add(Duration(days: 5)).millisecondsSinceEpoch ~/ 1000,
    };

    return [jwt.createToken(payload), uuid];
  }

  bool validateToken(String token) {
    if (!jwt.verifyToken(token)) {
      return false;
    }
    Map<String, dynamic> payload = jwt.decodePayload(token);
    if (payload.containsKey('exp')) {
      int expiry = payload['exp'];
      DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
      if (DateTime.now().isAfter(expiryDate)) {
        return false;
      }
      return true;
    }
    return false;
  }

  Map<String, dynamic> getInfo(token) {
    return jwt.decodePayload(token);
  }
}
