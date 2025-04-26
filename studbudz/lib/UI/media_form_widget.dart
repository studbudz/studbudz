import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaFormWidget extends StatefulWidget {
  final Function submit;
  const MediaFormWidget({Key? key, required this.submit}) : super(key: key);

  @override
  _MediaFormWidgetState createState() => _MediaFormWidgetState();
}

class _MediaFormWidgetState extends State<MediaFormWidget> {
  final _subjectController = TextEditingController();
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  // multi-platform file format.
  XFile? _file;
  bool _isPrivate = false;

  Future<void> _pickMedia() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _file = picked;
      });
    }
  }

  void _submit() {
    final subject = _subjectController.text.trim();
    final caption = _captionController.text.trim();
    final data = <String, dynamic>{
      'type': 'media',
      'subject': subject,
      'post_url': _file?.path,
      'post_content': caption,
      'post_private': _isPrivate,
    };
    widget.submit(data);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subject input
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              onChanged: (_) {
                setState(() {});
              },
            ),
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
            // Caption input
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
            // Submit button
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
