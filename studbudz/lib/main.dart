import 'package:flutter/material.dart';
import 'package:studubdz/Engine/engine.dart';
//import 'package:studubdz/UI/feed_page.dart';
import 'package:studubdz/UI/home_page.dart';
//import 'package:studubdz/UI/post_widget.dart';
//import 'package:studubdz/UI/recovery_page.dart'; // Import RecoveryPage
import 'package:studubdz/UI/settings_page.dart';
import 'package:studubdz/UI/schedule_page.dart';
import 'package:studubdz/UI/sign_up.dart';
import 'package:studubdz/UI/theme_data.dart';
import 'package:studubdz/UI/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Controller(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final CustomTheme theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    final Controller controller = Provider.of<Controller>(context);
    Engine engine = Engine();
    engine.setController(controller);
    controller.engine = engine;

    return MaterialApp(
      theme: theme.theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _buildPage(controller),
      ),
    );
  }

  Widget _buildPage(Controller controller) {
    print("Page: ${controller.currentPage}"); // Debugging

    if (!Controller().engine.isLoggedIn()) {
      return const SignUpPage();
    }

    switch (controller.currentPage) {
      case AppPage.signIn:
        return const SignInPage();
      case AppPage.signUp:
        return const SignUpPage();
      case AppPage.home:
        return const HomePage();
      case AppPage.schedule:
        return const SchedulePage();
      case AppPage.settings:
        return const SettingsPage();
      default:
        return const SignUpPage(); // Default to SignUpPage
    }
  }
}
