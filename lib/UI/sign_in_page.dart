import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            //title
            Padding(
              padding: const EdgeInsets.all(100.0),
              child: Text('Sign In', style: TextStyle(fontSize: 30.sp)),
            ),
            //username field
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 50),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'username *',
                ),
                validator: (String? value) {
                  return null;
                  //check if username is valid
                },
              ),
            ),
            //password
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 50),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password *',
                ),
                validator: (String? value) {
                  return null;
                  //check if username is valid
                },
              ),
            ),
            //passw
            TextButton(
              onPressed: () => print('Next'),
              child: const Text('Sign In'),
            )
          ],
        ),
      ),
    );
  }
}
