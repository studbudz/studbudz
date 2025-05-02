import 'package:flutter/material.dart';
import 'package:studubdz/UI/home_page.dart';
import 'package:studubdz/notifier.dart';
//change username inside account section and password\
//

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _isProfilePublic = true; // Default to public profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Controller().setPage(AppPage.home);
          },
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.settings, size: 80, color: Colors.grey),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Account'),
                  subtitle: Text(
                      _isProfilePublic ? 'Public Profile' : 'Private Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountSettingsPage(
                          isProfilePublic: _isProfilePublic,
                          onProfileVisibilityChanged: (newValue) {
                            setState(() {
                              _isProfilePublic = newValue;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() {
                        _notificationsEnabled = val;
                      });
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Account'),
                  subtitle: const Text(
                      'Permanently remove your account and all associated data'),
                  onTap: () => _confirmDeleteAccount(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text('Log Out'),
                  onTap: () {
                    setState(() {
                      Controller().engine.logOut();
                      Controller().setPage(AppPage.signIn);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteAccount(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class AccountSettingsPage extends StatefulWidget {
  final bool isProfilePublic;
  final ValueChanged<bool> onProfileVisibilityChanged;

  const AccountSettingsPage({
    super.key,
    required this.isProfilePublic,
    required this.onProfileVisibilityChanged,
  });

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late bool _isProfilePublic;

  @override
  void initState() {
    super.initState();
    _isProfilePublic = widget.isProfilePublic;
  }

  void _saveChanges() {
    widget.onProfileVisibilityChanged(_isProfilePublic);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isProfilePublic
            ? 'Your profile is now Public'
            : 'Your profile is now Private'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Profile Visibility'),
              subtitle:
                  Text(_isProfilePublic ? 'Public Profile' : 'Private Profile'),
              trailing: Switch(
                value: _isProfilePublic,
                onChanged: (val) {
                  setState(() {
                    _isProfilePublic = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
