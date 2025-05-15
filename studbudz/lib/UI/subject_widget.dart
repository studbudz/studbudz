import 'package:flutter/material.dart';
import 'package:studubdz/notifier.dart';

// A dropdown widget for selecting a subject/category from a list fetched from the backend.
// Notifies the parent widget when the selection changes.
//
// Parameters:
//   - onSubjectSelected: ValueChanged<int?>. Callback triggered with the selected subject ID or null.
class SubjectWidget extends StatefulWidget {
  final ValueChanged<int?> onSubjectSelected;

  const SubjectWidget({super.key, required this.onSubjectSelected});

  @override
  _SubjectWidgetState createState() => _SubjectWidgetState();
}

class _SubjectWidgetState extends State<SubjectWidget> {
  int? _selectedSubjectId; // Currently selected subject ID
  List<dynamic> _subjects = []; // List of available subjects

  // Fetches the list of subjects from the backend on initialization.
  @override
  void initState() {
    super.initState();
    getData();
  }

  // Calls the backend to retrieve subjects and updates the state.
  // Handles both success and empty/error cases.
  Future<void> getData() async {
    final result = await Controller().engine.getSubjects();
    final raw = result['subjects'];
    if (raw is List) {
      _subjects = raw;
    }
    if (!mounted) return;
    setState(() {});
  }

  // Builds the dropdown form field with fetched subjects.
  // Includes a "None" option for no selection.
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      decoration: const InputDecoration(
        labelText: 'Select Subject',
        border: OutlineInputBorder(),
      ),
      value: _selectedSubjectId,
      isExpanded: true,
      menuMaxHeight: kMinInteractiveDimension * 10,
      onChanged: (int? newId) {
        setState(() {
          _selectedSubjectId = newId;
        });
        widget.onSubjectSelected(newId); // Notify parent of selection
      },
      items: <DropdownMenuItem<int?>>[
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('None'),
        ),
        ..._subjects.map((item) {
          final id = item['subject_id'] as int?;
          final name = item['subject_name']?.toString() ?? '';
          return DropdownMenuItem<int?>(
            value: id,
            child: Text(name),
          );
        }),
      ],
    );
  }
}
