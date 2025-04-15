import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentBio;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentBio,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    Navigator.pop(context, {
      'name': nameController.text,
      'bio': bioController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
