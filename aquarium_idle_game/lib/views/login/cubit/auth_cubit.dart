import 'package:aquarium_idle_game/views/login/cubit/auth_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aquarium_idle_game/api/generated/lib/api.dart';
import 'package:flutter/foundation.dart';

class AuthCubit extends Cubit<AuthState> {
  static const String isLoggedInKey = 'is_logged_in';
  static const String usernameKey = 'username';

  final UserApi _userApi = UserApi(ApiClient(basePath: 'http://localhost:5000'));

  AuthCubit() : super(AuthInitial()) {
    checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    // In debug mode, clear auth status on hot reload for development
    if (kDebugMode) {
      await clearAuthStatus();
      emit(AuthUnauthenticated());
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(isLoggedInKey) ?? false;

    if (isLoggedIn) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> clearAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, false);
    await prefs.remove(usernameKey);
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      if (username.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(isLoggedInKey, true);
        await prefs.setString(usernameKey, username);

        emit(AuthAuthenticated());
      } else {
        emit(AuthError('Invalid username or password'));
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

      final userDto = UserDto(
        username: username,
        passwordHash: password, // In a real app, you should hash this
      );

      final response = await _userApi.userRegisterPost(userDto: userDto);

      if (response != null && response.data != null) {
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
    await prefs.setBool(isLoggedInKey, false);
    await prefs.remove(usernameKey);

    emit(AuthUnauthenticated());
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }
}
