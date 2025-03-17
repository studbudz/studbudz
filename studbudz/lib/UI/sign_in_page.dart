import 'package:flutter/material.dart';
import 'package:studubdz/notifier.dart';
import 'package:studubdz/UI/recovery_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          // Top Section: Title and Profile Logo
          const Expanded(
            flex: 2,
            child: SignInHeaderWidget(),
          ),
          // Middle Section: Username and Password Fields
          Expanded(
              flex: 2,
              child: SignInFormWidget(
                  usernameController: _usernameController,
                  passwordController: _passwordController)),

          // Bottom Section: Sign In Button
          Expanded(
            flex: 2,
            child: Center(
              child: SizedBox(
                width: screenWidth * 0.5,
                child: ElevatedButton(
                  onPressed: () => _handleSignIn(),
                  child: const Text('Sign In'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignIn() async {
    //server.validate username and password.
    //get uuid and token.
    //set both.
    //next page.
    String username = _usernameController.text;
    String password = _passwordController.text;

    print("Validating log in details.");

    bool success = await Controller().engine.logIn(username, password);

    if (success) {
      setState(() {
        Controller().setPage(AppPage.home);
      });
    } else {
      //return error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class SignInHeaderWidget extends StatefulWidget {
  const SignInHeaderWidget({super.key});

  @override
  State<SignInHeaderWidget> createState() => _SignInHeaderWidgetState();
}

class _SignInHeaderWidgetState extends State<SignInHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 20,
        ),
        Icon(
          Icons.person,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 10),
        Text(
          'Sign In',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class SignInFormWidget extends StatefulWidget {
  const SignInFormWidget(
      {super.key,
      required this.usernameController,
      required this.passwordController});

  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  State<SignInFormWidget> createState() => _SignInFormWidgetState();
}

class _SignInFormWidgetState extends State<SignInFormWidget> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: widget.usernameController,
            decoration: const InputDecoration(
              labelText: 'Username *',
              prefixIcon: Icon(
                Icons.person,
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password *',
              prefixIcon: const Icon(
                Icons.lock,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecoveryPage()),
                );
              },
              child: const Text('Forgot Password?'),
            ),
          ),
        ],
      ),
    );
  }
}
