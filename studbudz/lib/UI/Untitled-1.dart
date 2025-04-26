import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum PostType { text, media, event }

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  CreatePostPageState createState() => CreatePostPageState();
}

class CreatePostPageState extends State<CreatePostPage> {
  PostType _selectedType = PostType.text;

  // Common fields
  final TextEditingController _subjectIdController = TextEditingController();
  bool _isPrivate = false;

  // Text post
  final TextEditingController _textContentController = TextEditingController();

  // Media post
  XFile? _mediaFile;
  final TextEditingController _mediaCaptionController = TextEditingController();

  // Event post
  final TextEditingController _eventNameController = TextEditingController();
  XFile? _eventImageFile;
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _eventLocationNameController =
      TextEditingController();
  DateTime? _eventStartAt;
  DateTime? _eventEndAt;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia(
      {bool forEvent = false, bool pickVideo = false}) async {
    XFile? picked;
    if (pickVideo) {
      picked = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      picked = await _picker.pickImage(source: ImageSource.gallery);
    }
    if (picked != null) {
      setState(() {
        if (forEvent) {
          _eventImageFile = picked;
        } else {
          _mediaFile = picked;
        }
      });
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        _eventStartAt = dateTime;
      } else {
        _eventEndAt = dateTime;
      }
    });
  }

  void _submit() {
    final subjectId = int.tryParse(_subjectIdController.text);
    Map<String, dynamic> data;
    switch (_selectedType) {
      case PostType.text:
        data = {
          'type': 'text',
          'subject_id': subjectId,
          'post_content': _textContentController.text,
          'post_private': _isPrivate,
        };
        break;
      case PostType.media:
        data = {
          'type': 'media',
          'subject_id': subjectId,
          'post_url': _mediaFile?.path,
          'post_content': _mediaCaptionController.text,
          'post_private': _isPrivate,
        };
        break;
      case PostType.event:
        data = {
          'type': 'event',
          'subject_id': subjectId,
          'event_name': _eventNameController.text,
          'event_image': _eventImageFile?.path,
          'event_description': _eventDescriptionController.text,
          'event_location_name': _eventLocationNameController.text,
          'event_start_at': _eventStartAt?.toIso8601String(),
          'event_end_at': _eventEndAt?.toIso8601String(),
          'event_private': _isPrivate,
        };
        break;
    }
    //send data.
    print(data);
  }

  Widget _buildSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: PostType.values.map((type) {
        final label = type.toString().split('.').last.capitalize();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: _selectedType == type,
            onSelected: (_) => setState(() => _selectedType = type),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _subjectIdController,
          decoration: const InputDecoration(labelText: 'Subject ID'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Private'),
          value: _isPrivate,
          onChanged: (v) => setState(() => _isPrivate = v),
        ),
        const SizedBox(height: 12),
        if (_selectedType == PostType.text) ...[
          TextField(
            controller: _textContentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
        ],
        if (_selectedType == PostType.media) ...[
          ElevatedButton.icon(
            onPressed: () => _pickMedia(forEvent: false),
            icon: const Icon(Icons.photo_library),
            label: const Text('Pick Image/Video'),
          ),
          if (_mediaFile != null) Text('Selected: ${_mediaFile!.name}'),
          const SizedBox(height: 8),
          TextField(
            controller: _mediaCaptionController,
            decoration: const InputDecoration(
              labelText: 'Caption',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        if (_selectedType == PostType.event) ...[
          TextField(
            controller: _eventNameController,
            decoration: const InputDecoration(
              labelText: 'Event Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _pickMedia(forEvent: true),
            icon: const Icon(Icons.image),
            label: const Text('Pick Event Image'),
          ),
          if (_eventImageFile != null)
            Text('Selected: ${_eventImageFile!.name}'),
          const SizedBox(height: 8),
          TextField(
            controller: _eventDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _eventLocationNameController,
            decoration: const InputDecoration(
              labelText: 'Location Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pickDateTime(isStart: true),
                  child: Text(_eventStartAt == null
                      ? 'Pick Start'
                      : 'Start: ${_eventStartAt!.toLocal().toIso8601String()}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pickDateTime(isStart: false),
                  child: Text(_eventEndAt == null
                      ? 'Pick End'
                      : 'End: ${_eventEndAt!.toLocal().toIso8601String()}'),
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: 20),
        ElevatedButton(onPressed: _submit, child: Text('Submit')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSelector(),
              SizedBox(height: 16),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
