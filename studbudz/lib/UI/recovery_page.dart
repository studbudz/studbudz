import 'package:flutter/material.dart';

// A stateful widget that allows users to input their 24-word recovery phrase
// to restore access to their account. This is a critical security feature that
// should only be accessible through authenticated recovery flows.
//
// Parameters:
//   - key: Widget key for identification
//
class RecoveryPhrasePage extends StatefulWidget {
  const RecoveryPhrasePage({super.key});

  @override
  State<RecoveryPhrasePage> createState() => _RecoveryPhrasePageState();
}

// State class for [RecoveryPhrasePage]
//
// Manages:
// - 24 text controllers for phrase input fields
// - Recovery phrase validation and submission logic
// - UI state and interactions
class _RecoveryPhrasePageState extends State<RecoveryPhrasePage> {
  // List of text controllers for each of the 24 recovery phrase words
  //
  // Each controller corresponds to one word input field in the UI
  late List<TextEditingController> wordControllers;

  // Initializes the 24 text controllers when the widget is created
  @override
  void initState() {
    super.initState();
    wordControllers = List.generate(24, (index) => TextEditingController());
  }

  // Handles the recovery process when user confirms their phrase
  //
  // Current implementation:
  // - Placeholder for actual recovery logic
  // - Should be extended to:
  //   1. Validate phrase format and checksum
  //   2. Communicate with backend for account recovery
  //   3. Handle success/failure states
  //   4. Navigate to appropriate screen
  //
  void recover() {
    // TODO: Implement recovery logic
  }

  // Builds the recovery phrase input interface
  //
  // Returns a Scaffold containing:
  // - Warning header with security information
  // - Scrollable list of 24 input fields
  // - Confirmation button

  @override
  Widget build(BuildContext context) {
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
                  itemCount: 24,
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
                                controller: wordControllers[index],
                                textAlign: TextAlign.center,
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
              ElevatedButton(
                onPressed: recover,
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
