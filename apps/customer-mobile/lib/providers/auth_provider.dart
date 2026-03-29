import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  Future<void> init() async {
    await _api.loadTokens();
    if (_api.isLoggedIn) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userData = prefs.getString('user_data');
        if (userData != null) {
          _user = jsonDecode(userData);
          _isLoggedIn = true;
          notifyListeners();
        }
        // Refresh profile
        await fetchProfile();
        // Connect socket
        if (_api.accessToken != null) {
          SocketService().connect(_api.accessToken!);
        }
      } catch (_) {
        _isLoggedIn = false;
        notifyListeners();
      }
    }
  }

  Future<bool> requestOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.requestOtp(phone);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.verifyOtp(phone, code);
      _user = result['data']['user'];
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_user));
      _isLoading = false;
      notifyListeners();
      // Connect socket after login
      if (_api.accessToken != null) {
        SocketService().connect(_api.accessToken!);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final result = await _api.getProfile();
      _user = result['data'];
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_user));
      notifyListeners();
    } catch (_) {
      // Silent fail
    }
  }

  Future<void> logout() async {
    SocketService().disconnect();
    await _api.logout();
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
