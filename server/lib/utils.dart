import 'package:http_server/http_server.dart';

// holds form data, my brain died so I just made a class
class MultipartData {
  final Map<String, String> fields;
  final HttpBodyFileUpload? file;
  MultipartData({required this.fields, this.file});
}
