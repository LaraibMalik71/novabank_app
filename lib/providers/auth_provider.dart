import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;

  Map<String, dynamic>? get currentUser => _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (result != 'success') {
        _errorMessage = result;
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(
        email: email,
        password: password,
      );

      if (!success) {
        _errorMessage = 'Invalid email or password.';
        return false;
      }

      _isLoggedIn = true;
      _currentUser = await _authService.getUserByEmail(email);
      debugPrint('Logged-in user details: $_currentUser');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email.trim().toLowerCase());
      return true;
    } catch (e, stackTrace) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('LOGIN STACK TRACE: $stackTrace');

      _errorMessage = 'Login failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', false);

    _isLoggedIn = false;
    _currentUser = null;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      final email = prefs.getString('userEmail');

      if (email != null) {
        _currentUser = await _authService.getUserByEmail(email);
      }
    }

    notifyListeners();
  }

  Future<String?> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final userId = _currentUser?['id'] as int?;

    if (userId == null) {
      return 'Unable to find your account. Please log in again.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final error = await _authService.updateUserProfile(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
      );

      if (error != null) {
        _errorMessage = error;
        return error;
      }

      _currentUser = await _authService.getUserByEmail(email);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email.trim().toLowerCase());

      _errorMessage = null;
      return null;
    } catch (e) {
      _errorMessage = 'Unable to update profile. Please try again.';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userId = _currentUser?['id'] as int?;

    if (userId == null) {
      return 'Unable to find your account. Please log in again.';
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final error = await _authService.changePassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _errorMessage = error;
      return error;
    } catch (e) {
      _errorMessage = 'Unable to change password. Please try again.';
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
