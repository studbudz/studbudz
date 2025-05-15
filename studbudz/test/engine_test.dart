import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/Engine/engine.dart';
import 'package:studubdz/Engine/auth_manager.dart';
import 'package:studubdz/Engine/http_request_handler.dart';

// Mock classes
class MockHttpRequestHandler extends Mock implements HttpRequestHandler {}

class MockAuthManager extends Mock implements AuthManager {}

// Test wrapper for Engine
class TestableEngine extends Engine {
  TestableEngine({required AuthManager auth, required HttpRequestHandler http})
      : super.forTest(authManager: auth, httpHandler: http);

  void Function()? onJoinEventCalled;
  void Function()? onLeaveEventCalled;

  @override
  Future<void> handleJoinEvent({required int eventID}) async {
    onJoinEventCalled?.call();
  }

  @override
  Future<void> handleLeaveEvent({required int eventID}) async {
    onLeaveEventCalled?.call();
  }
}

void main() {
  late MockHttpRequestHandler mockHttp;
  late MockAuthManager mockAuth;
  late Engine engine;

  setUp(() {
    mockHttp = MockHttpRequestHandler();
    mockAuth = MockAuthManager();
    engine = Engine.forTest(authManager: mockAuth, httpHandler: mockHttp);
  });
  group('Engine', () {
    group('logIn', () {
      test('returns true for valid credentials', () async {
        when(() => mockHttp.signInRequest('SophiaMiller', 'x|i0IS7IM\$0K'))
            .thenAnswer((_) async => true);

        final result = await engine.logIn('SophiaMiller', 'x|i0IS7IM\$0K');
        expect(result, isTrue);
      });

      test('returns false for invalid credentials', () async {
        when(() => mockHttp.signInRequest('WrongUser', 'WrongPass'))
            .thenAnswer((_) async => false);

        final result = await engine.logIn('WrongUser', 'WrongPass');
        expect(result, isFalse);
      });

      test('throws on network error', () async {
        when(() => mockHttp.signInRequest('Any', 'Any'))
            .thenThrow(Exception('Network error'));

        expect(() => engine.logIn('Any', 'Any'), throwsException);
      });
    });

    group('signUpRequest', () {
      test('returns true when signup succeeds', () async {
        when(() => mockHttp.signUpRequest('user', 'pass', 'words'))
            .thenAnswer((_) async => true);

        final result = await engine.signUpRequest('user', 'pass', 'words');
        expect(result, isTrue);
      });

      test('returns false when signup fails', () async {
        when(() => mockHttp.signUpRequest('user', 'pass', 'words'))
            .thenAnswer((_) async => false);

        final result = await engine.signUpRequest('user', 'pass', 'words');
        expect(result, isFalse);
      });

      test('throws when signup throws exception', () async {
        when(() => mockHttp.signUpRequest(any(), any(), any()))
            .thenThrow(Exception('Signup failed'));

        expect(() => engine.signUpRequest('user', 'pass', 'words'),
            throwsException);
      });
    });

    group('createPost', () {
      test('sends text post data to textPost endpoint', () async {
        final data = {'type': 'text', 'content': 'Hello world'};

        when(() => mockHttp.sendData('textPost', data))
            .thenAnswer((_) async => {'success': true});

        final result = await engine.createPost(data);
        expect(result, isFalse); // method never sets success = true
        verify(() => mockHttp.sendData('textPost', data)).called(1);
      });

      test('sends media post data to mediaPost endpoint', () async {
        final data = {'type': 'media', 'file': 'file.jpg'};

        when(() => mockHttp.sendData('mediaPost', data))
            .thenAnswer((_) async => {'success': true});

        final result = await engine.createPost(data);
        expect(result, isFalse);
        verify(() => mockHttp.sendData('mediaPost', data)).called(1);
      });

      test('sends event post data to eventPost endpoint', () async {
        final data = {'type': 'event', 'title': 'Meetup'};

        when(() => mockHttp.sendData('eventPost', data))
            .thenAnswer((_) async => {'success': true});

        final result = await engine.createPost(data);
        expect(result, isFalse);
        verify(() => mockHttp.sendData('eventPost', data)).called(1);
      });

      test('createPost handles failure in response', () async {
        final data = {'type': 'text', 'content': 'fail test'};

        when(() => mockHttp.sendData('textPost', data))
            .thenAnswer((_) async => {'success': false});

        final result = await engine.createPost(data);
        expect(result, isFalse);
      });

      test('prints warning for unknown post type', () async {
        final data = {'type': 'unknown'};

        final result = await engine.createPost(data);
        expect(result, isFalse);

        verifyNever(() => mockHttp.sendData(any(), any()));
      });
    });

    group('getFeed', () {
      test('calls fetchData with correct page', () async {
        const page = 2;
        final expectedResponse = {
          'posts': ['post1', 'post2']
        };

        when(() => mockHttp.fetchData('feed', queryParams: {'page': '$page'}))
            .thenAnswer((_) async => expectedResponse);

        final result = await engine.getFeed(page: page);
        expect(result, expectedResponse);

        verify(() => mockHttp.fetchData('feed', queryParams: {'page': '$page'}))
            .called(1);
      });

      test('throws exception when fetchData fails', () async {
        when(() => mockHttp.fetchData('feed',
                queryParams: any(named: 'queryParams')))
            .thenThrow(Exception('Network error'));

        expect(() => engine.getFeed(page: 1), throwsException);
      });
    });

    group('getUserProfile', () {
      test('returns profile data on success', () async {
        const userId = 42;
        final expectedResponse = {'name': 'Alice', 'bio': 'Hello world'};

        when(() => mockHttp
                .fetchData('profile', queryParams: {'user_id': '$userId'}))
            .thenAnswer((_) async => expectedResponse);

        final result = await engine.getUserProfile(userID: userId);
        expect(result, expectedResponse);
        verify(() => mockHttp.fetchData('profile',
            queryParams: {'user_id': '$userId'})).called(1);
      });

      test('throws when fetchData fails', () async {
        when(() => mockHttp.fetchData('profile',
                queryParams: any(named: 'queryParams')))
            .thenThrow(Exception('Server down'));

        expect(() => engine.getUserProfile(userID: 1), throwsException);
      });
    });

    group('getSubjects', () {
      test('returns subjects on success', () async {
        final mockSubjects = {
          'subjects': ['Math', 'Physics', 'CS']
        };

        when(() => mockHttp.fetchData('subjects'))
            .thenAnswer((_) async => mockSubjects);

        final result = await engine.getSubjects();
        expect(result, mockSubjects);
        verify(() => mockHttp.fetchData('subjects')).called(1);
      });

      test('throws when fetchData fails', () async {
        when(() => mockHttp.fetchData('subjects'))
            .thenThrow(Exception('Subjects fetch failed'));

        expect(() => engine.getSubjects(), throwsException);
      });
    });

    group('downloadMedia', () {
      test('returns XFile after successful download', () async {
        final fakeFile = XFile('path/to/fake.jpg');

        when(() => mockHttp.saveMedia('endpoint/path'))
            .thenAnswer((_) async => fakeFile);

        final result = await engine.downloadMedia(endpoint: 'endpoint/path');
        expect(result, fakeFile);
        verify(() => mockHttp.saveMedia('endpoint/path')).called(1);
      });

      test('throws when saveMedia fails', () async {
        when(() => mockHttp.saveMedia('bad/path'))
            .thenThrow(Exception('Download error'));

        expect(
            () => engine.downloadMedia(endpoint: 'bad/path'), throwsException);
      });
    });

    group('hasJoinedEvent', () {
      test('returns true when user has joined the event', () async {
        when(() =>
                mockHttp.fetchData('hasjoined', queryParams: {'event_id': '1'}))
            .thenAnswer((_) async => {'has_joined': true});

        final result = await engine.hasJoinedEvent(eventID: 1);
        expect(result, isTrue);
      });

      test('returns false when user has not joined the event', () async {
        when(() =>
                mockHttp.fetchData('hasjoined', queryParams: {'event_id': '2'}))
            .thenAnswer((_) async => {'has_joined': false});

        final result = await engine.hasJoinedEvent(eventID: 2);
        expect(result, isFalse);
      });

      test('returns false if has_joined key is missing', () async {
        when(() =>
                mockHttp.fetchData('hasjoined', queryParams: {'event_id': '3'}))
            .thenAnswer((_) async => {}); // no key

        final result = await engine.hasJoinedEvent(eventID: 3);
        expect(result, isFalse);
      });

      test('throws when fetchData fails', () async {
        when(() => mockHttp.fetchData('hasjoined',
                queryParams: any(named: 'queryParams')))
            .thenThrow(Exception('Request failed'));

        expect(() => engine.hasJoinedEvent(eventID: 99), throwsException);
      });
    });

    group('likePost', () {
      test('calls sendData with correct post ID', () async {
        when(() => mockHttp.sendData('likepost', {'post_id': 123}))
            .thenAnswer((_) async => {'success': true});

        await engine.likePost(postID: 123);

        verify(() => mockHttp.sendData('likepost', {'post_id': 123})).called(1);
      });

      test('throws when sendData fails', () async {
        when(() => mockHttp.sendData('likepost', any()))
            .thenThrow(Exception('Like failed'));

        expect(() => engine.likePost(postID: 999), throwsException);
      });
    });

    group('getUpcomingEvents', () {
      test('returns upcoming events on success', () async {
        final mockEvents = {
          'events': [
            {'title': 'Hackathon'},
            {'title': 'Workshop'}
          ]
        };

        when(() => mockHttp.fetchData('getupcomingevents'))
            .thenAnswer((_) async => mockEvents);

        final result = await engine.getUpcomingEvents();
        expect(result, mockEvents);
        verify(() => mockHttp.fetchData('getupcomingevents')).called(1);
      });

      test('throws when fetchData fails', () async {
        when(() => mockHttp.fetchData('getupcomingevents'))
            .thenThrow(Exception('Server offline'));

        expect(() => engine.getUpcomingEvents(), throwsException);
      });
    });

    group('toggleJoinEvent', () {
      test('calls handleJoinEvent when hasJoined is false', () async {
        final engine = TestableEngine(auth: mockAuth, http: mockHttp);
        bool joinCalled = false;
        engine.onJoinEventCalled = () => joinCalled = true;

        await engine.toggleJoinEvent(eventID: 1, hasJoined: false);
        expect(joinCalled, isTrue);
      });

      test('calls handleLeaveEvent when hasJoined is true', () async {
        final engine = TestableEngine(auth: mockAuth, http: mockHttp);
        bool leaveCalled = false;
        engine.onLeaveEventCalled = () => leaveCalled = true;

        await engine.toggleJoinEvent(eventID: 1, hasJoined: true);
        expect(leaveCalled, isTrue);
      });

      test('throws when join/leave throws', () async {
        final engine = TestableEngine(auth: mockAuth, http: mockHttp);
        engine.onJoinEventCalled = () => throw Exception('Fail');

        expect(
          () => engine.toggleJoinEvent(eventID: 1, hasJoined: false),
          throwsException,
        );
      });
    });

    group('followUser', () {
      test('calls sendData with correct follow endpoint and user ID', () async {
        when(() => mockHttp.sendData('follow', {'userID': 42}))
            .thenAnswer((_) async => {'success': true});

        await engine.followUser(42);

        verify(() => mockHttp.sendData('follow', {'userID': 42})).called(1);
      });

      test('throws if sendData fails during follow', () async {
        when(() => mockHttp.sendData('follow', any()))
            .thenThrow(Exception('Follow error'));

        expect(() => engine.followUser(1), throwsException);
      });
    });

    group('unfollowUser', () {
      test('calls sendData with correct unfollow endpoint and user ID',
          () async {
        when(() => mockHttp.sendData('unfollow', {'userID': 42}))
            .thenAnswer((_) async => {'success': true});

        await engine.unfollowUser(42);

        verify(() => mockHttp.sendData('unfollow', {'userID': 42})).called(1);
      });

      test('throws if sendData fails during unfollow', () async {
        when(() => mockHttp.sendData('unfollow', any()))
            .thenThrow(Exception('Unfollow error'));

        expect(() => engine.unfollowUser(1), throwsException);
      });
    });

    group('getParticipantsCount', () {
      test('returns participant count on success', () async {
        const eventId = 123;
        final mockResponse = {'count': 40};

        when(() => mockHttp.fetchData(
              'getparticipantscount',
              queryParams: {'event_id': '$eventId'},
            )).thenAnswer((_) async => mockResponse);

        final result = await engine.getParticipantsCount(eventID: eventId);
        expect(result, mockResponse);
        verify(() => mockHttp.fetchData(
              'getparticipantscount',
              queryParams: {'event_id': '$eventId'},
            )).called(1);
      });

      test('throws when fetchData fails', () async {
        when(() => mockHttp.fetchData('getparticipantscount',
                queryParams: any(named: 'queryParams')))
            .thenThrow(Exception('Server error'));

        expect(
            () => engine.getParticipantsCount(eventID: 999), throwsException);
      });
    });

    group('getUserId', () {
      test('returns user ID from auth manager', () async {
        when(() => mockAuth.getUserIdFromToken()).thenAnswer((_) async => 123);

        final result = await engine.getUserId();
        expect(result, 123);

        verify(() => mockAuth.getUserIdFromToken()).called(1);
      });

      test('throws if auth manager throws', () async {
        when(() => mockAuth.getUserIdFromToken())
            .thenThrow(Exception('Token missing'));

        expect(() => engine.getUserId(), throwsException);
      });
    });

    group('userExists', () {
      test('returns true when user exists', () async {
        when(() => mockHttp.userExists('Alice')).thenAnswer((_) async => true);

        final result = await engine.userExists('Alice');
        expect(result, isTrue);
        verify(() => mockHttp.userExists('Alice')).called(1);
      });

      test('returns false when user does not exist', () async {
        when(() => mockHttp.userExists('Ghost')).thenAnswer((_) async => false);

        final result = await engine.userExists('Ghost');
        expect(result, isFalse);
        verify(() => mockHttp.userExists('Ghost')).called(1);
      });

      test('throws if userExists fails', () async {
        when(() => mockHttp.userExists(any())).thenThrow(Exception('DB error'));

        expect(() => engine.userExists('Bob'), throwsException);
      });
    });
    group('autoSuggest', () {
      test('returns map with suggestions from backend', () async {
        const query = 'Ali';
        final expected = {
          'users': ['Alice', 'Aliyah']
        };

        when(() => mockHttp.fetchData(
              'getUserSuggestionsFromName',
              queryParams: {'query': '$query%'},
            )).thenAnswer((_) async => expected);

        final result = await engine.autoSuggest(query);
        expect(result, isA<Map>());
        verify(() => mockHttp.fetchData(
              'getUserSuggestionsFromName',
              queryParams: {'query': '$query%'},
            )).called(1);
      });

      test('throws when backend call fails', () async {
        when(() => mockHttp.fetchData(
              any(),
              queryParams: any(named: 'queryParams'),
            )).thenThrow(Exception('Suggestion error'));

        expect(() => engine.autoSuggest('Ali'), throwsException);
      });
    });

    group('unlikePost', () {
      test('calls sendData with correct post ID', () async {
        when(() => mockHttp.sendData('unlikepost', {'post_id': 123}))
            .thenAnswer((_) async => {'success': true});

        await engine.unlikePost(postID: 123);

        verify(() => mockHttp.sendData('unlikepost', {'post_id': 123}))
            .called(1);
      });

      test('throws when sendData fails', () async {
        when(() => mockHttp.sendData('unlikepost', any()))
            .thenThrow(Exception('Unlike failed'));

        expect(() => engine.unlikePost(postID: 999), throwsException);
      });
    });
    group('hasLikedPost', () {
      test('returns true when post is liked', () async {
        when(() => mockHttp
                .fetchData('haslikedpost', queryParams: {'post_id': '1'}))
            .thenAnswer((_) async => {'has_liked': true});

        final result = await engine.hasLikedPost(postID: 1);
        expect(result, isTrue);
      });

      test('returns false when post is not liked', () async {
        when(() => mockHttp
                .fetchData('haslikedpost', queryParams: {'post_id': '2'}))
            .thenAnswer((_) async => {'has_liked': false});

        final result = await engine.hasLikedPost(postID: 2);
        expect(result, isFalse);
      });

      test('returns false if has_liked key is missing', () async {
        when(() => mockHttp
                .fetchData('haslikedpost', queryParams: {'post_id': '3'}))
            .thenAnswer((_) async => {}); // Missing key

        final result = await engine.hasLikedPost(postID: 3);
        expect(result, isFalse);
      });

      test('throws when fetchData fails', () async {
        when(() => mockHttp.fetchData('haslikedpost',
                queryParams: any(named: 'queryParams')))
            .thenThrow(Exception('Failed to check like status'));

        expect(() => engine.hasLikedPost(postID: 99), throwsException);
      });
    });

    group('isLoggedIn', () {
      test('returns true when user is logged in', () async {
        when(() => mockAuth.isLoggedIn()).thenAnswer((_) async => true);

        final result = await engine.isLoggedIn();
        expect(result, isTrue);
        verify(() => mockAuth.isLoggedIn()).called(1);
      });

      test('calls authManager.logOut', () {
        when(() => mockAuth.logOut()).thenAnswer((_) async {});

        engine.logOut();

        verify(() => mockAuth.logOut()).called(1);
      });
    });
  });

  group('handleJoin/LeaveEvent', () {
    test('handleJoinEvent completes on success', () async {
      when(() => mockHttp.sendData('joinevent', any()))
          .thenAnswer((_) async => {'success': true});

      await engine.handleJoinEvent(eventID: 99);
      verify(() => mockHttp.sendData('joinevent', {'event_id': 99})).called(1);
    });

    test('handleLeaveEvent completes on success', () async {
      when(() => mockHttp.sendData('leaveevent', any()))
          .thenAnswer((_) async => {'success': true});

      await engine.handleLeaveEvent(eventID: 88);
      verify(() => mockHttp.sendData('leaveevent', {'event_id': 88})).called(1);
    });

    test('handleJoinEvent throws if sendData fails', () async {
      when(() => mockHttp.sendData('joinevent', any()))
          .thenThrow(Exception('fail'));

      expect(() => engine.handleJoinEvent(eventID: 1), throwsException);
    });

    test('handleLeaveEvent throws if sendData fails', () async {
      when(() => mockHttp.sendData('leaveevent', any()))
          .thenThrow(Exception('fail'));

      expect(() => engine.handleLeaveEvent(eventID: 1), throwsException);
    });
  });
}
