// lib/services/audio_service.dart
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _player.setAsset('assets/audio/aquarium_background_music.mp3');
      await _player.setLoopMode(LoopMode.all);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isInitialized) await initialize();

    final prefs = await SharedPreferences.getInstance();
    final isMusicEnabled = prefs.getBool('musicEnabled') ?? true;

    if (isMusicEnabled) {
      try {
        await _player.play();
      } catch (e) {
        debugPrint('Error playing music: $e');
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_isInitialized) {
      await _player.pause();
    }
  }

  Future<void> toggleMusic(bool enabled) async {
    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
    _isInitialized = false;
  }
}