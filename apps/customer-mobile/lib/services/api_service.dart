import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _accessToken;
  String? _refreshToken;

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
  }

  bool get isLoggedIn => _accessToken != null;
  String? get accessToken => _accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: data['error']?.toString() ?? 'An error occurred',
    );
  }

  // Auth methods
  Future<Map<String, dynamic>> requestOtp(String phone) async {
    return post('/auth/request-otp', {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String code, {
    String role = 'CUSTOMER',
  }) async {
    final result = await post('/auth/verify-otp', {
      'phone': phone,
      'code': code,
      'role': role,
    });
    if (result['data'] != null) {
      await saveTokens(
        result['data']['accessToken'],
        result['data']['refreshToken'],
      );
    }
    return result;
  }

  Future<void> logout() async {
    try {
      await post('/auth/logout', {});
    } catch (_) {
      // Ignore logout errors
    }
    await clearTokens();
  }

  // User methods
  Future<Map<String, dynamic>> getProfile() async {
    return get('/users/me');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return patch('/users/me', data);
  }

  // Ride methods
  Future<Map<String, dynamic>> getFareEstimate(Map<String, dynamic> data) async {
    return post('/rides/fare-estimate', data);
  }

  Future<Map<String, dynamic>> createRideRequest(Map<String, dynamic> data) async {
    return post('/rides', data);
  }

  Future<Map<String, dynamic>> getRideRequests({String? status}) async {
    String endpoint = '/rides';
    if (status != null) endpoint += '?status=$status';
    return get(endpoint);
  }

  Future<Map<String, dynamic>> getRideById(String id) async {
    return get('/rides/$id');
  }

  Future<Map<String, dynamic>> cancelRide(String id) async {
    return delete('/rides/$id');
  }

  // Offer methods
  Future<Map<String, dynamic>> respondToOffer(String offerId, String action) async {
    return post('/offers/$offerId/respond', {'action': action});
  }

  // Trip methods
  Future<Map<String, dynamic>> getTrips({int page = 1}) async {
    return get('/trips?page=$page');
  }

  Future<Map<String, dynamic>> getTripById(String id) async {
    return get('/trips/$id');
  }

  // Rating
  Future<Map<String, dynamic>> rateTrip(Map<String, dynamic> data) async {
    return post('/ratings', data);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
