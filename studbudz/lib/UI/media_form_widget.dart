import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studubdz/UI/subject_widget.dart';

class MediaFormWidget extends StatefulWidget {
  final Function submit;
  const MediaFormWidget({super.key, required this.submit});

  @override
  _MediaFormWidgetState createState() => _MediaFormWidgetState();
}

class _MediaFormWidgetState extends State<MediaFormWidget> {
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _file;
  bool _isPrivate = false;
  int? subject;

  Future<void> _pickMedia() async {
    final picked = await _picker.pickMedia();
    if (picked != null) {
      setState(() {
        _file = picked;
      });
    }
  }

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

  @override
  void dispose() {
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
