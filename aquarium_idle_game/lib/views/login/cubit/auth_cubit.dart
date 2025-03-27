import 'package:aquarium_idle_game/pref_constants.dart';
import 'package:aquarium_idle_game/views/login/cubit/auth_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aquarium_idle_game/api/generated/lib/api.dart';
import 'package:flutter/foundation.dart';

class AuthCubit extends Cubit<AuthState> {
  final UserApi _userApi = UserApi(ApiClient(basePath: 'http://localhost:5000'));

  AuthCubit() : super(AuthInitial()) {
    checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    // In debug mode, clear auth status on hot reload for development
    // if (kDebugMode) {
    //   await clearAuthStatus();
    //   emit(AuthUnauthenticated());
    //   return;
    // }

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(PrefConstants.isLoggedInKey) ?? false;

    if (isLoggedIn) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> clearAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefConstants.isLoggedInKey, false);
    await prefs.remove(PrefConstants.usernameKey);
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());

    try {
      final userDto = UserDto(username: username, passwordHash: password);

      final response = await _userApi.userLoginPost(userDto: userDto);

      if (response != null && response.errorMessage != null) {
        emit(AuthError(response.errorMessage!));
        return;
      }

      if (response != null && response.data != null) {
        _saveUserData(username, response.data!.id!);

        emit(AuthAuthenticated());
      } else {
        emit(AuthError('Login error: ${response?.errorMessage}'));
      }
    } catch (e) {
      emit(AuthError('Login error: $e'));
    }
  }

  Future<void> register(String username, String password) async {
    emit(AuthLoading());

    try {
      if (username.length < 3 || password.length < 6) {
        emit(AuthError('Username must be at least 3 characters and password at least 6 characters'));
        return;
      }

      final userDto = UserDto(username: username, passwordHash: password);

      final response = await _userApi.userRegisterPost(userDto: userDto);

      if (response != null && response.data != null) {
        _saveUserData(username, response.data!.id!);

        emit(AuthAuthenticated());
      } else {
        emit(AuthError('Registration failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError('Registration error: $e'));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefConstants.isLoggedInKey, false);
    await prefs.remove(PrefConstants.usernameKey);
    await prefs.remove(PrefConstants.userIdKey);

    emit(AuthUnauthenticated());
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefConstants.usernameKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefConstants.isLoggedInKey) ?? false;
  }

  Future<void> _saveUserData(String username, int userId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(PrefConstants.isLoggedInKey, true);
    await prefs.setString(PrefConstants.usernameKey, username);
    await prefs.setInt(PrefConstants.userIdKey, userId);
  }
}
