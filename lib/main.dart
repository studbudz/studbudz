import 'package:flutter/material.dart';
import 'package:studubdz/UI/feed_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:studubdz/UI/home_page.dart';
import 'package:studubdz/UI/post_widget.dart';
import 'package:studubdz/UI/sign_up.dart';
import 'package:studubdz/UI/theme_data.dart';

void main() {
  runApp(
    ScreenUtilInit(
      //android emulator screen size
      designSize: Size(411, 914),
      builder: (context, child) => MyApp(),
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
    return MaterialApp(
      theme: theme.theme,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
    return const Scaffold(body: SignUpPage());
  }
}
