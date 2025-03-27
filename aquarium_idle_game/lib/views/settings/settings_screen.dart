// lib/views/settings/settings_screen.dart
import 'package:aquarium_idle_game/pref_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isMusicEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMusicEnabled = prefs.getBool('musicEnabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _toggleMusic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', value);
    setState(() {
      _isMusicEnabled = value;
    });
    // You would call your audio service here to start/stop music
    if (value) {
      debugPrint('Music enabled');
      // AudioService.play();
    } else {
      debugPrint('Music disabled');
      // AudioService.pause();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefConstants.isLoggedInKey, false);
    await prefs.remove(PrefConstants.usernameKey);
    await prefs.remove(PrefConstants.userIdKey);

    if (context.mounted) {
      // Navigate to login screen and clear navigation history
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Audio Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Background Music'),
                    subtitle: const Text('Enable/disable game music'),
                    value: _isMusicEnabled,
                    onChanged: _toggleMusic,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    subtitle: const Text('Sign out of your account'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _logout();
                              },
                              child: const Text('LOGOUT'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}