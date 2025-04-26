import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:studubdz/Engine/engine.dart';
import 'package:studubdz/UI/create_post_page.dart';
import 'package:studubdz/UI/feed_page.dart';
import 'package:studubdz/UI/home_page.dart';
import 'package:studubdz/UI/post_widget.dart';
import 'package:studubdz/UI/recovery_page.dart';
import 'package:studubdz/UI/settings_page.dart';
import 'package:studubdz/UI/schedule_page.dart';
import 'package:studubdz/UI/sign_up.dart';
import 'package:studubdz/UI/theme_data.dart';
import 'package:studubdz/UI/sign_in_page.dart';
import 'package:studubdz/UI/profile_page.dart';
import 'package:studubdz/UI/chat_page.dart';
import 'package:provider/provider.dart';
import 'notifier.dart';

void main() {
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel', // Fixed mismatch here
          channelName: 'Basic Notifications',
          channelGroupKey: 'basic_group',
          channelDescription: 'Notification channel for basic notifications',
        )
      ],
      debug: true);

  runApp(
    ChangeNotifierProvider(
      create: (context) => Controller(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final CustomTheme theme = CustomTheme();
  late Controller controller;
  late Engine engine;

  @override
  void initState() {
    super.initState();

    // Request notification permissions
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
    controller.init();
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
      controller.isInBackground = false;
    } else {
      controller.isInBackground = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Controller>(context);
    return MaterialApp(
      theme: theme.theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _buildPage(controller),
      ),
    );
  }

  void triggerNotification() {
    controller.triggerNotification(
      'basic_channel',
      'basic_group',
      'Basic Notification',
      'Simple notification',
    );
  }

  // Method to switch pages based on controller's page
  Widget _buildPage(Controller controller) {
    print("Current Page: ${controller.currentPage}");

    switch (controller.currentPage) {
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
      case AppPage.settings:
        return const SettingsPage(); // Fixed syntax error
      case AppPage.profile:
        return const ProfilePage();
      case AppPage.recovery:
        return const RecoveryPhrasePage();
      case AppPage.postWidget:
        return const PostWidget();
      default:
        // return TestWidget(
        //   onTriggerNotification: triggerNotification, // Fixed typo
        // );
        return CreatePostPage();
    }
  }
}

// Test Widget with notification button
class TestWidget extends StatefulWidget {
  final VoidCallback onTriggerNotification; // Fixed typo

  const TestWidget({super.key, required this.onTriggerNotification});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: widget.onTriggerNotification, // Fixed typo
          child: const Text('Trigger Notification'),
        ),
      ),
    );
  }
}
