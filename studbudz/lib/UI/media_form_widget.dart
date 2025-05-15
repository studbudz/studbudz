import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/subject_widget.dart';

// A form widget for creating and submitting media posts (images or videos).
//
// Parameters:
//   - submit: Function. Callback to handle the submission of the media post data.
//     The callback receives a Map<String, dynamic> containing:
//       - type: 'media'
//       - subject: selected subject/category (optional)
//       - file: the picked XFile (image or video)
//       - post_content: caption text
//       - post_private: privacy flag (bool)
//
class MediaFormWidget extends StatefulWidget {
  final Function submit;
  const MediaFormWidget({super.key, required this.submit});
// State for MediaFormWidget
//
// Handles media picking, caption input, privacy toggle, and subject selection.
// Maintains the state of the selected file, caption text, and privacy flag.

  @override
  _MediaFormWidgetState createState() => _MediaFormWidgetState();
}

class _MediaFormWidgetState extends State<MediaFormWidget> {
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _file;
  bool _isPrivate = false;
  int? subject;

  // Opens the media picker for the user to select an image or video.
  // Updates _file with the selected media.
  Future<void> _pickMedia() async {
    final picked = await _picker.pickMedia();
    if (picked != null) {
      setState(() {
        _file = picked;
      });
    }
  }

  // Collects all form data and triggers the submit callback.
  // The data map includes type, subject, file, caption, and privacy flag.

  void _submit() {
    final caption = _captionController.text.trim();
    final data = <String, dynamic>{
      'type': 'media',
      'subject': subject,
      'file': _file,
      'post_content': caption,
      'post_private': _isPrivate,
    };
    widget.submit(data);
  }

// Disposes the caption controller to free resources and prevent memory leaks.
  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  // Builds the media post form UI.
  // Includes subject selection, media picker, privacy toggle, caption input, and submit button.
  // Uses a StatefulBuilder for local state updates (for better performance in some cases).
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubjectWidget(
                onSubjectSelected: (value) => setState(() {
                      subject = value;
                    })),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickMedia,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Image/Video'),
            ),
            if (_file != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Selected: ${_file!.name}'),
              ),
            const SizedBox(height: 16),
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
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
