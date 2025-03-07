import 'package:flutter/material.dart';
import 'package:studubdz/Engine/engine.dart';
import 'package:studubdz/UI/feed_page.dart';
import 'package:studubdz/UI/home_page.dart';
import 'package:studubdz/UI/post_widget.dart';
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
    final Controller notifier = Provider.of<Controller>(context, listen: false);
    Engine engine = Engine();
    engine.setController(notifier);
    notifier.engine = engine;

    return MaterialApp(
      theme: theme.theme,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Studbudz home page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Controller controller = Controller();

  @override
  Widget build(BuildContext context) {
    switch (controller.page) {
      case 'signIn':
        return const SignInPage();
      case 'signUp':
        return const SignUpPage();
      case 'homePage':
        return const HomePage();
      default:
        return const HomePage();
    }
  }
}
