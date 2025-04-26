import 'package:flutter/material.dart';

class TextFormWidget extends StatefulWidget {
  final Function submit;
  const TextFormWidget({super.key, required this.submit});

  @override
  State<TextFormWidget> createState() => _TextFormWidgetState();
}

class _TextFormWidgetState extends State<TextFormWidget> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  bool _isPrivate = false;

  void _submitIfNotEmpty() {
    if (_controller.text.trim().isNotEmpty) {
      final data = {
        'type': 'text',
        'subject': _subjectController.text.trim(),
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
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              onChanged: (value) {
                setState(() {});
              },
            ),
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
