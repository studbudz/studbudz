import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:studubdz/Engine/engine.dart';
import 'package:studubdz/UI/feed_page.dart';
import 'package:studubdz/UI/home_page.dart';
import 'package:studubdz/UI/post_widget.dart';
import 'package:studubdz/UI/schedule_page.dart';
import 'package:studubdz/UI/sign_up.dart';
import 'package:studubdz/UI/theme_data.dart';
import 'package:studubdz/UI/sign_in_page.dart';
import 'package:studubdz/UI/profile_page.dart';
import 'package:studubdz/UI/chat_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'notifier.dart';

void main() {
  AwesomeNotifications().initialize(
      null,
      [
        //channels for granular control and settings page.
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'basic notifications',
            channelGroupKey: 'basic_group',
            channelDescription: 'notification channel for basic notifications')
      ],
      debug: true);
  runApp(
    ChangeNotifierProvider(
      create: (context) => Controller(),
      child: MyApp(),
    ),
  );
}

//placeholder code
//use for testing each UI
class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isInBackground = false;
  final CustomTheme theme = CustomTheme();
  late Controller controller;
  late Engine engine;

  @override
  void initState() {
    //store decision if no so we don't spam them every time.
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Initialize the controller and engine
    controller = Provider.of<Controller>(context, listen: false);
    engine = Engine();
    engine.setController(controller);
    controller.engine = engine;
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('AppLifecycleState: ${state.toString()}');
    if (state == AppLifecycleState.resumed) {
      isInBackground = false;
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      isInBackground = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme.theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _buildPage(controller),
      ),
    );
  }

  // Method to switch pages based on controller's page
  Widget _buildPage(Controller controller) {
    print("Page: ${controller.currentPage}"); // Debugging

    // weird logic but allows hard coding of default page through controller.currentPage.
    // if (!Controller().engine.isLoggedIn()) {
    // return const SignUpPage();
    // }

    switch (controller.currentPage) {
      // enum AppPage { signIn, signUp, home, profile, settings }
      case AppPage.signIn:
        return const SignInPage();
      case AppPage.signUp:
        return const SignUpPage();
      case AppPage.home:
        return const HomePage();
      case AppPage.schedule:
        return const SchedulePage();
      case AppPage.feed:
        return const FeedPage();
      case AppPage.chat:
        return const ChatPage();
      case AppPage.profile:
        return const ProfilePage();
      case AppPage.postWidget:
        return const PostWidget();
      default:
        return const TestWidget(); // Default to SignUpPage
    }
  }
}

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  triggerNotification() {
    index += 1;
    //unique id allows for multiple notifications to be displayed
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: index,
            channelKey: 'basic_channel',
            groupKey: 'basic_group',
            title: 'Simple Notification',
            body: 'Simple body'));
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: triggerNotification,
            child: const Text('Trigger Notification')),
      ),
    );
  }
}
