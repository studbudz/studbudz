import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:studubdz/UI/home_page.dart';
import 'package:studubdz/notifier.dart';

// Checks if a user with the given username already exists in the backend.
// Returns true if the username is taken, false otherwise.
Future<bool> checkUserExists(String username) async {
  print("Checking if user exists: $username");
  return Controller().engine.userExists(username);
}

// Validates password complexity according to the following rules:
// - At least 8 characters
// - Contains uppercase, lowercase, digit, and special character
// Returns true if the password is strong, false otherwise.
Future<bool> validatePasswordComplexity(String password) async {
  if (password.length < 8) return false;

  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;

  for (var char in password.runes) {
    if (char >= 65 && char <= 90) hasUppercase = true; // A-Z
    if (char >= 97 && char <= 122) hasLowercase = true; // a-z
    if (char >= 48 && char <= 57) hasDigit = true; // 0-9
    if (!((char >= 65 && char <= 90) ||
        (char >= 97 && char <= 122) ||
        (char >= 48 && char <= 57))) {
      hasSpecialChar = true; // Special character
    }
  }
  return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
}

// Sends a sign-up request to the backend with the provided username, password, and recovery phrase.
// Returns true if sign-up is successful, false otherwise.
Future<bool> signUp(String username, String password, String words) async {
  print("Signing up with: $username and $password");
  final response = await Controller().engine.signUpRequest(
        username,
        password,
        words,
      );
  return response;
}

// Generates a new BIP39 mnemonic phrase (24 words, 256-bit strength).
Future<String> generateMnemonic() async {
  return bip39.generateMnemonic(strength: 256);
}

// A stateful widget that implements the multi-step sign-up flow:
// 1. Account setup (username, password)
// 2. Recovery phrase generation and confirmation
// 3. Phrase verification
// 4. Completion and navigation to home page
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int step = 0; // Tracks the current step in the sign-up flow
  String username = '';
  String password = '';
  String confirmPassword = '';
  String words = '';
  List<TextEditingController> wordControllers = [];

  // Disposes all text controllers for the phrase input fields.
  @override
  void dispose() {
    for (var c in wordControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // Advances to the next step, handling validation and state as needed.
  void nextStep() {
    switch (step) {
      case 0:
        _handleAccountSetup();
        break;
      case 1:
        _handleWordGenerationConfirmed();
        break;
      case 2:
        _handleWordVerification();
        break;
    }
  }

  // Handles validation and state for the account setup step.
  // Checks for empty fields, password match, username uniqueness, and password strength.
  Future<void> _handleAccountSetup() async {
    if (username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid input")));
      return;
    }
    if (await checkUserExists(username)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Username is taken")));
      return;
    }
    if (!await validatePasswordComplexity(password)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Weak password")));
      return;
    }
    setState(() => step = 1);
    final generated = await generateMnemonic();
    setState(() {
      words = generated;
      wordControllers = List.generate(
        generated.split(' ').length,
        (_) => TextEditingController(),
      );
    });
  }

  // Confirms that the recovery phrase has been generated and moves to the verification step.
  Future<void> _handleWordGenerationConfirmed() async {
    if (words.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No phrase")));
      return;
    }
    setState(() => step = 2);
  }

  // Verifies that the user has correctly entered the recovery phrase.
  // If correct, attempts sign-up with the backend.
  Future<void> _handleWordVerification() async {
    final entered = wordControllers.map((c) => c.text.trim()).join(' ');
    if (entered != words) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Phrase mismatch")));
      return;
    }
    bool success = await signUp(username, password, words);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign up failed. Try again.")),
      );
      return;
    }
    setState(() => step = 3);
  }

  // Builds the UI for each step in the sign-up flow.
  @override
  Widget build(BuildContext context) {
    if (step == 3) {
      // Completion screen
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("All done!"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Go to Home', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      );
    }
    // Render the appropriate step widget
    switch (step) {
      case 0:
        return AccountSetup(
          onStepContinue: nextStep,
          onUsernameChanged: (v) => username = v,
          onPasswordChanged: (v) => password = v,
          onConfirmPasswordChanged: (v) => confirmPassword = v,
        );
      case 1:
        return WordGeneration(words: words, onStep: nextStep);
      case 2:
        return WordVerification(
          words: words,
          controllers: wordControllers,
          onStep: nextStep,
        );
      default:
        return const Placeholder();
    }
  }
}

// Stateless widget for the account setup step of sign-up.
// Allows users to enter username, password, and confirm password.
// Calls [onStepContinue] when the user presses "Next".
class AccountSetup extends StatelessWidget {
  const AccountSetup({
    super.key,
    required this.onStepContinue,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
  });

  final VoidCallback onStepContinue;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(50.0),
                child: Text('Sign Up', style: TextStyle(fontSize: 30)),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Username *'),
                  onChanged: onUsernameChanged,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Password *'),
                  obscureText: true,
                  onChanged: onPasswordChanged,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: TextField(
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password *'),
                  obscureText: true,
                  onChanged: onConfirmPasswordChanged,
                ),
              ),
              ElevatedButton(
                onPressed: onStepContinue,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Displays the generated recovery phrase to the user and allows them to copy it.
// User must confirm before proceeding to the next step.
class WordGeneration extends StatefulWidget {
  const WordGeneration({super.key, required this.words, required this.onStep});
  final String words;
  final VoidCallback onStep;

  @override
  State<WordGeneration> createState() => _WordGenerationState();
}

class _WordGenerationState extends State<WordGeneration> {
  bool copied = false;

  // Copies the recovery phrase to the clipboard and shows a confirmation.
  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.words));
    setState(() => copied = true);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Recovery phrase copied!")));
  }

  @override
  Widget build(BuildContext context) {
    final wordList = widget.words.split(' ');
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.key, size: 60),
              const SizedBox(height: 10),
              const Text('Your Recovery Phrase',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text(
                  'These words are your account recovery phrase. Never share them.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              // List of recovery words (read-only)
              Expanded(
                child: ListView.builder(
                  itemCount: wordList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text('${index + 1}.',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: Offset(0, 4))
                              ], borderRadius: BorderRadius.circular(10)),
                              child: TextField(
                                readOnly: true,
                                controller: TextEditingController(
                                    text: wordList[index]),
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Copy and Confirm buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: copyToClipboard,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.all(12),
                        shape: const CircleBorder()),
                    child:
                        const Icon(Icons.copy, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: widget.onStep,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text('Confirm',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stateless widget for verifying the recovery phrase.
// User must enter each word in the correct order to proceed.
class WordVerification extends StatelessWidget {
  const WordVerification(
      {super.key,
      required this.words,
      required this.controllers,
      required this.onStep});
  final String words;
  final List<TextEditingController> controllers;
  final VoidCallback onStep;

  // Handles input for each word field, auto-advancing if multiple words are pasted at once.
  void handleInput(int index, String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return;
    controllers[index].text = parts.first;
    controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: controllers[index].text.length));
    final remaining = parts.sublist(1);
    if (remaining.isNotEmpty && index + 1 < controllers.length) {
      handleInput(index + 1, remaining.join(' '));
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordsList = words.split(' ');
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.key, size: 60),
              const SizedBox(height: 10),
              const Text('Confirm Recovery Phrase',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              // Input fields for each recovery word
              Expanded(
                child: ListView.builder(
                  itemCount: wordsList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text('${index + 1}.',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: Offset(0, 4))
                              ], borderRadius: BorderRadius.circular(10)),
                              child: TextField(
                                controller: controllers[index],
                                textAlign: TextAlign.center,
                                onChanged: (v) => handleInput(index, v),
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Confirm button
              ElevatedButton(
                onPressed: onStep,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Confirm',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
