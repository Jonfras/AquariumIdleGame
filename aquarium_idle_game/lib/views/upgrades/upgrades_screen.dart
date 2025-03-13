// lib/screens/upgrades_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importiere go_router

class UpgradesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrades'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verbessere dein Spiel!',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}