import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:mocktail/mocktail.dart';
import 'package:studubdz/Engine/http_request_handler.dart';
import 'package:studubdz/Engine/auth_manager.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' show BaseRequest;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakeBaseRequest extends Fake implements BaseRequest {}

class MockHttpClient extends Mock implements http.Client {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockAuthManager extends Mock implements AuthManager {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

class FakeUri extends Fake implements Uri {}

class FakeStreamTransformer extends Fake
    implements StreamTransformer<List<int>, Object?> {}

class FakePathProvider extends PathProviderPlatform {
  final String? overridePath;

  FakePathProvider([this.overridePath]);

  @override
  Future<String> getTemporaryPath() async {
    return overridePath ?? (await Directory.systemTemp.createTemp()).path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HttpRequestHandler handler;
  late MockHttpClient mockClient;
  late MockHttpClientRequest mockRequest;
  late MockHttpClientResponse mockResponse;
  late MockAuthManager mockAuthManager;
  late MockHttpHeaders mockHeaders;

  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(FakeStreamTransformer());
    registerFallbackValue(FakeBaseRequest());
    PathProviderPlatform.instance = FakePathProvider();
  });

  setUp(() {
    mockClient = MockHttpClient();
    mockRequest = MockHttpClientRequest();
    mockResponse = MockHttpClientResponse();
    mockAuthManager = MockAuthManager();
    mockHeaders = MockHttpHeaders();

    handler = HttpRequestHandler.forTest(
      address: 'http://localhost',
      authManager: mockAuthManager,
      client: mockClient,
    );
  });

  group('HttpRequestHandler', () {
    group('signInRequest', () {
      test('returns true on status 200 with token and uuid', () async {
        final mockResponseData = jsonEncode({'token': 'abc', 'uuid': '123'});

        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(mockResponseData, 200));

        when(() => mockAuthManager.saveAuthData(any(), any()))
            .thenAnswer((_) async => {});

        final result = await handler.signInRequest('user', 'pass');
        expect(result, isTrue);
      });

      test('throws on non-200 response', () async {
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('Unauthorized', 401));

        expect(
          () => handler.signInRequest('user', 'pass'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws if _client.post throws', () async {
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(Exception('Network failure'));

        expect(
          () => handler.signInRequest('user', 'pass'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signUpRequest', () {
      test('returns true on status 200', () async {
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('{}', 200));

        final result =
            await handler.signUpRequest('user', 'pass', 'test words');
        expect(result, isTrue);
      });

      test('throws on non-200 response', () async {
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('Bad Request', 400));

        expect(
          () => handler.signUpRequest('user', 'pass', 'test words'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws if _client.post throws', () async {
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(Exception('Network down'));

        expect(
          () => handler.signUpRequest('user', 'pass', 'test words'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
  group('userExists', () {
    test('returns true when server returns {"exists": true}', () async {
      when(() => mockClient.get(
                any(),
                headers: any(named: 'headers'),
              ))
          .thenAnswer(
              (_) async => http.Response(jsonEncode({'exists': true}), 200));

      final result = await handler.userExists('testuser');
      expect(result, isTrue);
    });

    test('returns false when server returns {"exists": false}', () async {
      when(() => mockClient.get(
                any(),
                headers: any(named: 'headers'),
              ))
          .thenAnswer(
              (_) async => http.Response(jsonEncode({'exists': false}), 200));

      final result = await handler.userExists('unknown');
      expect(result, isFalse);
    });

    test('throws on non-200 response', () async {
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('Error', 404));

      expect(
        () => handler.userExists('erroruser'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws if _client.get throws', () async {
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenThrow(Exception('No connection'));

      expect(
        () => handler.userExists('crashuser'),
        throwsA(isA<Exception>()),
      );
    });
  });
  group('fetchData', () {
    test('returns parsed JSON on 200 response', () async {
      when(() => mockAuthManager.getToken())
          .thenAnswer((_) async => 'valid-token');

      when(() => mockClient.get(
                any(),
                headers: any(named: 'headers'),
              ))
          .thenAnswer(
              (_) async => http.Response(jsonEncode({'msg': 'hello'}), 200));

      final result = await handler.fetchData('test');
      expect(result, {'msg': 'hello'});
    });

    test('throws on empty token', () async {
      when(() => mockAuthManager.getToken()).thenAnswer((_) async => '');

      expect(
        () => handler.fetchData('test'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws on non-200/201 response', () async {
      when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () => handler.fetchData('test'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws if _client.get throws', () async {
      when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenThrow(Exception('Network issue'));

      expect(
        () => handler.fetchData('test'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('sendData', () {
    test('sends JSON if no XFile present and returns response data', () async {
      when(() => mockAuthManager.getToken())
          .thenAnswer((_) async => 'test-token');

      final responseMap = {'status': 'success'};
      when(() => mockClient.post(
                any(),
                headers: any(named: 'headers'),
                body: any(named: 'body'),
              ))
          .thenAnswer((_) async => http.Response(jsonEncode(responseMap), 200));

      final result = await handler.sendData('submit', {
        'name': 'shaun',
        'age': 25,
      });

      expect(result, responseMap);
    });

    test('throws if response status is not 200/201', () async {
      when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Bad Request', 400));

      expect(
        () => handler.sendData('submit', {'name': 'shaun'}),
        throwsA(isA<Exception>()),
      );
    });

    test('sendData uses default contentType for unknown file types', () async {
      when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

      final tempDir = Directory.systemTemp;
      final tempFile =
          await File('${tempDir.path}/file.unknown').writeAsBytes([1, 2, 3]);

      final unknownFile = XFile(tempFile.path, name: 'file.unknown');

      final stream = Stream<List<int>>.fromIterable([
        utf8.encode(jsonEncode({'ok': true}))
      ]);
      final streamedResponse = http.StreamedResponse(stream, 200);

      when(() => mockClient.send(any()))
          .thenAnswer((_) async => streamedResponse);

      final result = await handler.sendData('upload', {'file': unknownFile});
      expect(result['ok'], true);
    });
  });

  group('sendData (multipart)', () {
    test('uploads file using MultipartRequest and returns parsed response',
        () async {
      when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

      // Simulate an XFile with dummy path and name
      final tempDir = Directory.systemTemp;
      final tempFile =
          await File('${tempDir.path}/fake.jpg').writeAsBytes([0, 1, 2]);

      final fakeFile = XFile(tempFile.path, name: 'fake.jpg');

      // Create a mock response stream
      final stream = Stream<List<int>>.fromIterable([
        utf8.encode(jsonEncode({'uploaded': true}))
      ]);
      final streamedResponse = http.StreamedResponse(stream, 200);

      when(() => mockClient.send(any()))
          .thenAnswer((_) async => streamedResponse);

      final result = await handler.sendData('upload', {
        'description': 'test',
        'file': fakeFile,
      });

      expect(result, {'uploaded': true});
    });

    test('throws if multipart upload fails with error status', () async {
      when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

      final fakeFile = XFile('/path/fail.jpg', name: 'fail.jpg');

      final stream = Stream<List<int>>.fromIterable([utf8.encode('error')]);
      final badResponse = http.StreamedResponse(stream, 400);

      when(() => mockClient.send(any())).thenAnswer((_) async => badResponse);

      expect(
        () => handler.sendData('upload', {'file': fakeFile}),
        throwsA(isA<Exception>()),
      );
    });

    test('sendData uses default contentType for unknown file types', () async {
      when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

      final tempDir = Directory.systemTemp;
      final tempFile =
          await File('${tempDir.path}/file.unknown').writeAsBytes([1, 2, 3]);

      final unknownFile = XFile(tempFile.path, name: 'file.unknown');

      final stream = Stream<List<int>>.fromIterable([
        utf8.encode(jsonEncode({'ok': true}))
      ]);
      final streamedResponse = http.StreamedResponse(stream, 200);

      when(() => mockClient.send(any()))
          .thenAnswer((_) async => streamedResponse);

      final result = await handler.sendData('upload', {'file': unknownFile});
      expect(result['ok'], true);
    });
  });

  test('uploads file using MultipartRequest and returns parsed response',
      () async {
    when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

    final tempDir = Directory.systemTemp;
    final tempFile =
        await File('${tempDir.path}/fake.jpg').writeAsBytes([1, 2, 3]);

    final fakeFile = XFile(tempFile.path, name: 'fake.jpg');

    final stream = Stream<List<int>>.fromIterable([
      utf8.encode(jsonEncode({'uploaded': true}))
    ]);
    final streamedResponse = http.StreamedResponse(stream, 200);

    when(() => mockClient.send(any()))
        .thenAnswer((_) async => streamedResponse);

    final result = await handler.sendData('upload', {
      'description': 'test',
      'file': fakeFile,
    });

    expect(result, {'uploaded': true});
  });

  group('saveMedia', () {
    test('downloads file and returns XFile', () async {
      when(() => mockAuthManager.getToken())
          .thenAnswer((_) async => 'test-token');

      final fakeBytes = [1, 2, 3];
      final response = http.Response.bytes(
        fakeBytes,
        200,
        headers: {'content-type': 'image/png'},
      );

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => response);

      final result = await handler.saveMedia('media/file123');

      expect(result, isA<XFile>());
      expect(await File(result.path).readAsBytes(), fakeBytes);
      expect(result.name.endsWith('.png'), isTrue);
    });

    test('throws if download fails with status ≠ 200', () async {
      when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        () => handler.saveMedia('media/missing'),
        throwsA(isA<Exception>()),
      );
    });
  });

  test('returns cached file if already exists', () async {
    when(() => mockAuthManager.getToken()).thenAnswer((_) async => 'token');

    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('should not be called', 500));

    final endpoint = 'media/file123.png';
    final ext = p.extension(endpoint);
    final baseName = 'media_${endpoint.replaceAll('/', '_')}';

    final tempDir = await Directory.systemTemp.createTemp();
    final cachedPath = p.join(tempDir.path, '$baseName$ext');

    // Manually write a file that should be found by saveMedia
    await File(cachedPath).writeAsBytes([1, 2, 3]);

    // Use handler configured to use that temp directory
    PathProviderPlatform.instance = FakePathProvider(tempDir.path);
    final result = await handler.saveMedia(endpoint);

    expect(result.path, cachedPath);
    expect(await File(result.path).readAsBytes(), [1, 2, 3]);
  });

  group('checkConnection', () {
    test('prints Connected. on 202 response', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response('', 202));

      await handler.checkConnection();
    });

    test('prints failure message on non-202 response', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response('', 500));

      await handler.checkConnection();
    });

    test('prints error message on exception', () async {
      when(() => mockClient.get(any())).thenThrow(Exception('network fail'));

      await handler.checkConnection();
    });
  });
}
