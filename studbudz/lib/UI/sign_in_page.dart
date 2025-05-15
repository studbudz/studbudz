import 'package:flutter/material.dart';
import 'package:studubdz/UI/sign_up_page.dart';
import 'package:studubdz/notifier.dart';

// A stateful page for user authentication. Allows users to sign in with username and password.
// Handles validation, error feedback, and navigation to the home page or sign up page.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Builds the sign-in UI, including header, form, and sign-in button.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Section: Title and Profile Logo
              const SignInHeaderWidget(),
              // Middle Section: Username and Password Fields
              SignInFormWidget(
                usernameController: _usernameController,
                passwordController: _passwordController,
              ),
              // Bottom Section: Sign In Button
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.5,
                  child: ElevatedButton(
                    key: const Key('loginButton'),
                    onPressed: () => _handleSignIn(),
                    child: const Text('Sign In'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Validates input and attempts to sign in using the backend.
  // Shows error messages for missing fields or failed authentication.
  void _handleSignIn() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    // Validate that both fields are filled
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Attempt sign in via backend engine
    bool success = await Controller().engine.logIn(username, password);

    if (success) {
      print("Login successful, navigating to home page.");
      setState(() {
        Controller()
            .setPage(AppPage.home); // Ensure this is set to `AppPage.home`
      });
    } else {
      // Show error if authentication fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Displays the sign-in page header with an icon and title.
class SignInHeaderWidget extends StatelessWidget {
  const SignInHeaderWidget({super.key});

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

// Form widget for entering username and password.
// Includes password visibility toggle and navigation to sign up page.
//
// Parameters:
//   - usernameController: TextEditingController for the username field
//   - passwordController: TextEditingController for the password field
class SignInFormWidget extends StatefulWidget {
  const SignInFormWidget({
    super.key,
    required this.usernameController,
    required this.passwordController,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  State<SignInFormWidget> createState() => _SignInFormWidgetState();
}

class _SignInFormWidgetState extends State<SignInFormWidget> {
  bool _obscurePassword = true; // Controls password visibility

  // Builds the form UI with validation and password visibility toggle.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: const Key('usernameField'),
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
          // Password input field with visibility toggle
          TextFormField(
            key: const Key('passwordField'),
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
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(),
                  ),
                );
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
