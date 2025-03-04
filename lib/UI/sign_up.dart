import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;

Future<String> generateMnemonic() async {
  return '${bip39.generateMnemonic()} ${bip39.generateMnemonic()}';
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int step = 0;
  late String words;

  void nextStep() {
    setState(() {
      step++;

      if (step == 1) {
        generateWords();
      }
    });
  }

  Future<void> generateWords() async {
    final generatedWords = await generateMnemonic();
    setState(() {
      words = generatedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return AccountSetup(
          onStepContinue: nextStep,
        );
      case 1:
        //words generation
        return WordGeneration(
          words: words,
          onStep: nextStep,
        );
      case 2:
        //words confirmation or back
        //make account creation request to server
        return WordVerification(
          words: words,
          onStep: nextStep,
        );
      case 3:
        //send user to login page
        return const Placeholder();
      default:
        return const Placeholder();
    }
  }
}

class AccountSetup extends StatefulWidget {
  const AccountSetup({super.key, required this.onStepContinue});

  final VoidCallback onStepContinue;

  @override
  State<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            //title
            const Padding(
              padding: EdgeInsets.all(100.0),
              child: Text('Sign Up', style: TextStyle(fontSize: 30)),
            ),
            //username field
            Padding(
              padding: EdgeInsets.fromLTRB(50, 0, 50, 50),
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
            //confirm password
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 50),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirm Password *',
                ),
                validator: (String? value) {
                  return null;
                  //check if username is valid
                },
              ),
            ),
            //passw
            TextButton(
              onPressed: () => widget.onStepContinue(),
              child: const Text('Next'),
            )
          ],
        ),
      ),
    );
  }
}

class WordGeneration extends StatefulWidget {
  const WordGeneration({
    super.key,
    required this.words,
    required this.onStep,
  });

  final String words;
  final VoidCallback onStep;

  @override
  State<WordGeneration> createState() => _WordGenerationState();
}

class _WordGenerationState extends State<WordGeneration> {
  @override
  Widget build(BuildContext context) {
    final wordList = widget.words.split(' ');
    return Center(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(100.0),
            child: Text(
              'Recovery',
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, childAspectRatio: 3),
            itemCount: wordList.length,
            itemBuilder: (BuildContext context, int index) {
              return TextField(
                controller: TextEditingController(text: wordList[index]),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 4, horizontal: 8)),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                readOnly: true,
              );
            },
          ),
          const Text(
            'These words are your account recovery phrase. If you lose access to your account, you can use these words to reset your password. Never share these words with anyone.',
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () => widget.onStep(),
            child: const Text('Next'),
          )
        ],
      ),
    );
  }
}

class WordVerification extends StatefulWidget {
  const WordVerification(
      {super.key, required this.words, required this.onStep});

  final String words;
  final VoidCallback onStep;

  @override
  State<WordVerification> createState() => _WordVerificationState();
}

class _WordVerificationState extends State<WordVerification> {
  //when pressing enter or space the next controller should request attention
  late List<TextEditingController> wordControllers;

  @override
  void initState() {
    super.initState();
    wordControllers = List.generate(
        widget.words.split(' ').length, (index) => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    final List<String> wordsList = widget.words.split(' ');
    //send information to the server and get a token and a UUID in return.
    //UUID verifies device, token used to check if a user is logged in.
    return Center(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(100.0),
            child: Text(
              'Confirm Recovery Phrase',
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, childAspectRatio: 3),
            itemCount: wordsList.length,
            itemBuilder: (context, index) {
              return TextField(
                controller: wordControllers[index],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4, // Minimal vertical padding
                    horizontal: 8,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white, // White text
                ),
                textAlign: TextAlign.center,
              );
            },
          )
        ],
      ),
    );
  }
}
