import 'package:flutter/material.dart';
import 'package:studubdz/notifier.dart';

class SubjectWidget extends StatefulWidget {
  final ValueChanged<int?> onSubjectSelected;

  const SubjectWidget({super.key, required this.onSubjectSelected});

  @override
  _SubjectWidgetState createState() => _SubjectWidgetState();
}

class _SubjectWidgetState extends State<SubjectWidget> {
  int? _selectedSubjectId;
  List<dynamic> _subjects = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final result = await Controller().engine.getSubjects();
    final raw = result['subjects'];
    if (raw is List) {
      _subjects = raw;
    }
    if (!mounted) return;
    setState(() {});
  }

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
        widget.onSubjectSelected(newId);
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
