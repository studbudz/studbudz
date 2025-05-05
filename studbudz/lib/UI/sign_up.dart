import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bip39/bip39.dart' as bip39;

Future<String> generateMnemonic() async {
  return bip39.generateMnemonic(strength: 256);
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int step = 0;
  String username = '';
  String password = '';
  String confirmPassword = '';
  String words = '';
  List<TextEditingController> wordControllers = [];

  void nextStep() {
    setState(() {
      step++;
      if (step == 1) generateWords();
    });
  }

  Future<void> generateWords() async {
    final generatedWords = await generateMnemonic();
    setState(() {
      words = generatedWords;
      wordControllers = List.generate(
        words.split(' ').length,
        (_) => TextEditingController(),
      );
    });
  }

  void onUsernameChanged(String val) {
    print("Username: $val");
    setState(() {
      username = val;
    });
  }

  void onPasswordChanged(String val) {
    print("Password: $val");
    setState(() {
      password = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return AccountSetup(
          onStepContinue: nextStep,
          onUsernameChanged: onUsernameChanged,
          onPasswordChanged: onPasswordChanged,
          onConfirmPasswordChanged: (val) => confirmPassword = val,
        );
      case 1:
        return WordGeneration(words: words, onStep: nextStep);
      case 2:
        return WordVerification(
          words: words,
          controllers: wordControllers,
          onStep: () {
            // Here you can handle sending all data to your server
            print("Username: $username");
            print("Password: $password");
            print("Recovery Phrase: $words");
            print(
                "Entered Words: ${wordControllers.map((c) => c.text).join(' ')}");
            nextStep();
          },
        );
      default:
        return const Placeholder();
    }
  }
}

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

class WordGeneration extends StatefulWidget {
  const WordGeneration({super.key, required this.words, required this.onStep});
  final String words;
  final VoidCallback onStep;

  @override
  State<WordGeneration> createState() => _WordGenerationState();
}

class _WordGenerationState extends State<WordGeneration> {
  bool copied = false;

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.words));
    setState(() {
      copied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recovery phrase copied!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordList = widget.words.split(' ');

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.key, size: 60, color: Colors.black),
              const SizedBox(height: 10),
              const Text(
                'Your Recovery Phrase',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'These words are your account recovery phrase. If you lose access, use them to restore your account. **Never share them with anyone!**',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                readOnly: true,
                                controller: TextEditingController(
                                    text: wordList[index]),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                  border: InputBorder.none,
                                ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: copyToClipboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(12),
                      shape: const CircleBorder(),
                    ),
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

class WordVerification extends StatelessWidget {
  const WordVerification({
    super.key,
    required this.words,
    required this.controllers,
    required this.onStep,
  });

  final String words;
  final List<TextEditingController> controllers;
  final VoidCallback onStep;

  void handleInput(int index, String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return;

    // Set current controller to first word
    controllers[index].text = words.first;

    // Move cursor to the end
    controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: controllers[index].text.length),
    );

    // Get remaining words
    final remaining = words.sublist(1);

    if (remaining.isNotEmpty && index + 1 < controllers.length) {
      final nextValue = remaining.join(' ');
      handleInput(
          index + 1, nextValue); // Recursively send to the next controller
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.key, size: 60, color: Colors.black),
              const SizedBox(height: 10),
              const Text(
                'Confirm Recovery Phrase',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: controllers[index],
                                textAlign: TextAlign.center,
                                onChanged: (val) {
                                  handleInput(index, val);
                                },
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                  border: InputBorder.none,
                                ),
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
