// lib/api/game_data_service.dart
import 'package:aquarium_idle_game/views/login/cubit/auth_cubit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GameDataService {
  static const String baseUrl = 'https://yourapiurl.com/api';
  final AuthCubit _authCubit;

  GameDataService(this._authCubit);

  Future<Map<String, dynamic>> getUserGameData() async {
    final isLoggedIn = await _authCubit.isLoggedIn();
    final username = await _authCubit.getUsername();

    if (!isLoggedIn || username == null) {
      throw Exception('Not authenticated');
    }

    // For development, just return mock data
    return {
      'coins': 100,
      'username': username,
      'fishes': [
        {'id': 1, 'name': 'Goldfish', 'count': 2},
        {'id': 2, 'name': 'Clownfish', 'count': 1},
      ]
    };

    // Real implementation would be:
    /*
    final response = await http.get(
      Uri.parse('$baseUrl/users/$username/game-data'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load game data');
    }
    */
  }

  Future<bool> saveUserGameData(Map<String, dynamic> gameData) async {
    final isLoggedIn = await _authCubit.isLoggedIn();
    final username = await _authCubit.getUsername();

    if (!isLoggedIn || username == null) {
      throw Exception('Not authenticated');
    }

    // For development, just return success
    return true;

    // Real implementation would be:
    /*
    final response = await http.put(
      Uri.parse('$baseUrl/users/$username/game-data'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(gameData),
    );

    return response.statusCode == 200;
    */
  }
}