import 'package:flutter/material.dart';
import 'package:studubdz/UI/subject_widget.dart';

// A form widget for creating and submitting text posts.
// Allows users to select a subject, set privacy, and enter post content.
// Notifies the parent widget with the post data when submitted.
//
// Parameters:
//   - submit: Function. Callback to handle the submission of the text post data.
//     The callback receives a Map<String, dynamic> containing:
//       - type: 'text'
//       - subject: selected subject/category (optional)
//       - post_content: the text content
//       - post_private: privacy flag (bool)

class TextFormWidget extends StatefulWidget {
  final Function submit;
  const TextFormWidget({super.key, required this.submit});

  @override
  State<TextFormWidget> createState() => _TextFormWidgetState();
}

// State for TextFormWidget
//
// Handles subject selection, privacy toggle, text input, and submission logic.
class _TextFormWidgetState extends State<TextFormWidget> {
  final TextEditingController _controller =
      TextEditingController(); // Controller for text input
  bool _isPrivate = false; // Privacy flag for the post
  int? subject; // Selected subject/category (optional)

  // Submits the post if the text is not empty.
  // Packages the data into a map and calls the parent-provided submit callback.
  void _submitIfNotEmpty() {
    if (_controller.text.trim().isNotEmpty) {
      final data = {
        'type': 'text',
        'subject': subject,
        'post_content': _controller.text.trim(),
        'post_private': _isPrivate,
      };
      widget.submit(data);
    }
  }

  // Builds the text post form UI.
  // Includes subject selection, privacy toggle, text input, and a submit button.
  // Uses a StatefulBuilder for local state updates (for efficient UI refresh).
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // Subject input box (optional, can be used for categorization)
            SubjectWidget(
                onSubjectSelected: (value) => setState(() {
                      subject = value;
                    })),
            const SizedBox(height: 16),
            // Private toggle switch
            Row(
              children: [
                Switch(
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                ),
                const Text('Private'),
              ],
            ),
            const SizedBox(height: 16),
            // Text input field for post content
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter text',
                border: const OutlineInputBorder(),
                counterText: '${_controller.text.length}/500',
                counterStyle: const TextStyle(fontSize: 14),
              ),
              maxLength: 500,
              minLines: 9,
              maxLines: 9,
              onChanged: (value) {
                setState(() {}); // Updates character counter
              },
              onFieldSubmitted: (value) {
                _submitIfNotEmpty();
              },
            ),
            const SizedBox(height: 16),
            // Submit button
            ElevatedButton(
              onPressed: _submitIfNotEmpty,
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
