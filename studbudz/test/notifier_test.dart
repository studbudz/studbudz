import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studubdz/Engine/engine.dart';
import 'package:studubdz/notifier.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

// Mocks
class MockEngine extends Mock implements Engine {}

class FakeNotificationContent extends Fake implements NotificationContent {}

void main() {
  late Controller controller;
  late MockEngine mockEngine;

  setUpAll(() {
    registerFallbackValue(FakeNotificationContent());
  });

  setUp(() {
    controller = Controller();
    mockEngine = MockEngine();
    controller.setEngine(mockEngine);
    controller.isInBackground = true;
    controller.notifications.clear();
  });

  group('Notifier', () {
    group('init', () {
      test('sets currentPage to signIn when not logged in', () async {
        when(() => mockEngine.isLoggedIn()).thenAnswer((_) async => false);

        await controller.init();

        expect(controller.currentPage, AppPage.signIn);
        expect(controller.loggedIn, isFalse);
      });

      test('sets currentPage to home when logged in', () async {
        when(() => mockEngine.isLoggedIn()).thenAnswer((_) async => true);

        await controller.init();

        expect(controller.currentPage, AppPage.home);
        expect(controller.loggedIn, isTrue);
      });
    });

    group('setPage', () {
      test('navigates to signIn if not logged in', () {
        controller.loggedIn = false;

        controller.setPage(AppPage.settings);

        expect(controller.currentPage, AppPage.signIn);
      });

      test('navigates to target page if logged in', () {
        controller.loggedIn = true;

        controller.setPage(AppPage.profile);

        expect(controller.currentPage, AppPage.profile);
      });
    });

    group('triggerNotification', () {
      test('increments notification count when in background', () async {
        controller.isInBackground = true;
        controller.notifications.clear();

        controller.triggerNotification(
          'test_channel',
          'test_group',
          'Hello',
          'World',
        );

        final key = 'test_channeltest_group';
        expect(controller.notifications.containsKey(key), isTrue);
        expect(controller.notifications[key], equals(0));
      });

      test('does not increment notification count when not in background', () {
        controller.isInBackground = false;
        controller.notifications.clear();

        controller.triggerNotification(
          'test_channel',
          'test_group',
          'Hello',
          'World',
        );

        final key = 'test_channeltest_group';
        expect(controller.notifications.containsKey(key), isFalse);
      });
    });
  });
}
