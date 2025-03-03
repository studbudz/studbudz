import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          //title
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          //form
          Expanded(
            flex: 4,
            child: Placeholder(),
          ),
          //button
          Expanded(
            flex: 2,
            child: Center(
              child: ElevatedButton(
                  onPressed: () => print('button pressed!'),
                  child: Text('Sign In')),
            ),
          ),
        ],
      ),
    );
  }
}
