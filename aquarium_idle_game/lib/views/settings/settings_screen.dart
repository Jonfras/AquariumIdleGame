// lib/views/settings/settings_screen.dart
import 'package:aquarium_idle_game/pref_constants.dart';
import 'package:aquarium_idle_game/state_management/audio_service.dart';
import 'package:aquarium_idle_game/views/login/cubit/auth_cubit.dart';
import 'package:aquarium_idle_game/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

// In settings_screen.dart - update the _toggleMusic method
  Future<void> _toggleMusic(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', value);
    setState(() {
      _isMusicEnabled = value;
    });

    // Use AudioService to control music
    AudioService().toggleMusic(value);
  }

  Future<void> _logout() async {
    // Show logout dialog first
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldLogout || !context.mounted) return;

    // Get the AuthCubit and call its logout method
    final authCubit = BlocProvider.of<AuthCubit>(context);
    await authCubit.logout();

    // Navigation is now handled by the router which listens to AuthCubit state changes
    // No need to manually navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
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
                      onTap: () => _logout(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}