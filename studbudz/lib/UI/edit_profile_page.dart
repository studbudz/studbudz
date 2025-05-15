import 'package:flutter/material.dart';

// A stateful page that allows the user to edit their profile information (name and bio).
// Parameters:
//   - currentName: String. The user's current display name (used to pre-fill the name field).
//   - currentBio: String. The user's current bio (used to pre-fill the bio field).
//
// Returns:
//   - On save, pops the current page and returns a map with updated 'name' and 'bio' fields to the previous screen.

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

  // Initializes the text controllers with the current name and bio.
  // This ensures the fields are pre-filled for a better user experience.
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

  // Saves the updated profile information.
  //
  // Pops the current page and returns a map containing the new name and bio.
  // The parent widget should handle the update and backend synchronization.
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
