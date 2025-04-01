import 'package:flutter/material.dart';
import 'package:studubdz/Engine/engine.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:studubdz/config.dart';

enum AppPage {
  signIn,
  signUp,
  home,
  profile,
  settings,
  recovery,
  feed,
  schedule,
  feed,
  chat,
  settings,
  recovery, // Fixed enum name
  profile,
  postWidget
}

class Controller extends ChangeNotifier {
  //instantiates the controller internally
  static final Controller _instance = Controller._internal();
  Controller._internal();

  //technically shouldn't be public but
  //I wanted to avoid needing to access it via an intermediary function
  late Engine engine;
  AppPage currentPage = AppPage.recovery;
  bool isInBackground = true;
  bool loggedIn = false;
  Map<String, int> notifications = {};

  factory Controller() {
    return _instance; // always returns the same insance
  }

  Future<void> init() async {
    loggedIn = await engine.isLoggedIn();
    if (!loggedIn && logInCheck) {
      currentPage = AppPage.signIn;
    } else {
      currentPage = AppPage.settings;
    }
    print("Logged in is: $loggedIn and page is: $currentPage");
    notifyListeners();
  }

  void setEngine(Engine engine) {
    this.engine = engine;
  }

  Future<void> isLoggedIn() async {
    loggedIn = await engine.isLoggedIn();
    print("are we logged in? $loggedIn");
  }

  void setPage(AppPage page) {
    isLoggedIn();
    if (!loggedIn && logInCheck) {
      currentPage = AppPage.signIn;
    } else {
      currentPage = page;
    }
    print("set page to: ${currentPage}");
    notifyListeners();
  }

  void triggerNotification(
      String channelKey, String groupKey, String title, String body) {
    String notificationKey = "$channelKey$groupKey";
    if (isInBackground) {
      if (!notifications.containsKey(notificationKey)) {
        notifications[notificationKey] = 0;
      } else {
        notifications[notificationKey] = notifications[notificationKey]! + 1;
      }

      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: notifications[notificationKey]!,
              channelKey: channelKey,
              groupKey: groupKey,
              title: title,
              body: body));
    }
  }
}
