import 'package:flutter/material.dart';
import 'package:studubdz/Engine/engine.dart';
import 'package:studubdz/UI/feed_page.dart';
import 'package:studubdz/UI/home_page.dart';
import 'package:studubdz/UI/post_widget.dart';
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

//placeholder code
//use for testing each UI
class MyApp extends StatelessWidget {
  MyApp({super.key});

  final CustomTheme theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    // Access Controller via Provider
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

  // Method to switch pages based on controller's page
  Widget _buildPage(Controller controller) {
    print("Page: ${controller.currentPage}"); // Debugging

    //weird logic but allows hard coding of default page through controller.currentPage.
    if (!Controller().engine.isLoggedIn()) {
      return const SignInPage();
    }

    switch (controller.currentPage) {
      //enum AppPage { signIn, signUp, home, profile, settings }
      case AppPage.signIn:
        return const SignInPage();
      case AppPage.signUp:
        return const SignUpPage();
      case AppPage.home:
        return const HomePage();
      case AppPage.schedule:
        return const SchedulePage();
      default:
        return const SignUpPage(); // Default to SignUpPage
    }
  }
}
