import 'package:flutter/material.dart';
import 'package:studubdz/UI/subject_widget.dart';

class TextFormWidget extends StatefulWidget {
  final Function submit;
  const TextFormWidget({super.key, required this.submit});

  @override
  State<TextFormWidget> createState() => _TextFormWidgetState();
}

class _TextFormWidgetState extends State<TextFormWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isPrivate = false;
  int? subject;

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

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // Subject input box
            SubjectWidget(
                onSubjectSelected: (value) => setState(() {
                      subject = value;
                    })),
            const SizedBox(height: 16),
            // Private toggle
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
            // Text box
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
                setState(() {});
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
