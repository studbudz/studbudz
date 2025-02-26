import 'package:flutter/material.dart';
import 'package:studubdz/UI/nav_bar.dart';
import 'package:studubdz/UI/theme_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  CustomTheme theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme.theme,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
    return Scaffold(
      bottomNavigationBar: const navBarWidget(),
    );
  }
}
