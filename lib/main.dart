import 'package:flutter/material.dart';
import 'package:studubdz/UI/feed_page.dart';
import 'package:studubdz/UI/home_page.dart';
import 'package:studubdz/UI/post_widget.dart';
import 'package:studubdz/UI/sign_up.dart';
import 'package:studubdz/UI/theme_data.dart';
import 'package:studubdz/UI/sign_in_page.dart';

void main() {
  runApp(
    MyApp(),
  );
}

//placeholder code
//use for testing each UI
class MyApp extends StatelessWidget {
  MyApp({super.key});

  final CustomTheme theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
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
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SignInPage());
  }
}
