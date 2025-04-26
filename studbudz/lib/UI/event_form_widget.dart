import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EventFormWidget extends StatefulWidget {
  final Function submit;
  const EventFormWidget({Key? key, required this.submit}) : super(key: key);

  @override
  _EventFormWidgetState createState() => _EventFormWidgetState();
}

class _EventFormWidgetState extends State<EventFormWidget> {
  final _subjectController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventLocationController = TextEditingController();

  bool _isPrivate = false;
  DateTime? _eventStartAt;
  DateTime? _eventEndAt;
  XFile? _eventImage;

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _eventImage = picked);
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
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart)
        _eventStartAt = dt;
      else
        _eventEndAt = dt;
    });
  }

  void _submit() {
    final subjectText = _subjectController.text.trim();
    final subject = subjectText.isNotEmpty ? subjectText : null;
    final eventName = _eventNameController.text.trim();

    // if (eventName.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please enter Event Name.')),
    //   );
    //   return;
    // }

    final data = <String, dynamic>{
      'type': 'event',
      if (subject != null) 'subject': subject,
      'event_name': eventName,
      'event_image': _eventImage?.path,
      'event_description': _eventDescriptionController.text.trim(),
      'event_location_name': _eventLocationController.text.trim(),
      'event_start_at': _eventStartAt?.toIso8601String(),
      'event_end_at': _eventEndAt?.toIso8601String(),
      'event_private': _isPrivate,
    };

    widget.submit(data);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _eventLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subject input (optional)
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject (optional)',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),

          // Private toggle
          SwitchListTile(
            title: const Text('Private'),
            value: _isPrivate,
            onChanged: (value) => setState(() => _isPrivate = value),
          ),
          const SizedBox(height: 16),

          // Event Name input (required)
          TextFormField(
            controller: _eventNameController,
            decoration: const InputDecoration(
              labelText: 'Event Name',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),

          // Event Description
          TextFormField(
            controller: _eventDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Event Description',
              border: OutlineInputBorder(),
            ),
            maxLength: 500,
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 16),

          // Location input
          TextFormField(
            controller: _eventLocationController,
            decoration: const InputDecoration(
              labelText: 'Location Name',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),

          // Image picker
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text('Pick Event Image'),
          ),
          if (_eventImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Selected image: ${_eventImage!.name}'),
            ),
          const SizedBox(height: 16),

          // Date/time pickers
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pickDateTime(isStart: true),
                  child: Text(_eventStartAt == null
                      ? 'Pick Start Date'
                      : 'Start: ${_eventStartAt!.toLocal().toIso8601String()}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pickDateTime(isStart: false),
                  child: Text(_eventEndAt == null
                      ? 'Pick End Date'
                      : 'End: ${_eventEndAt!.toLocal().toIso8601String()}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit button
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
