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
    _accessToken = prefs.getString('driver_access_token');
    _refreshToken = prefs.getString('driver_refresh_token');
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_access_token', accessToken);
    await prefs.setString('driver_refresh_token', refreshToken);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_access_token');
    await prefs.remove('driver_refresh_token');
    await prefs.remove('driver_user_data');
  }

  bool get isLoggedIn => _accessToken != null;

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

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('${AppConstants.apiBaseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
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

  // Auth
  Future<Map<String, dynamic>> requestOtp(String phone) async {
    return post('/auth/request-otp', {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final result = await post('/auth/verify-otp', {
      'phone': phone,
      'code': code,
      'role': 'DRIVER',
    });
    if (result['data'] != null) {
      await saveTokens(result['data']['accessToken'], result['data']['refreshToken']);
    }
    return result;
  }

  Future<void> logout() async {
    try {
      await post('/auth/logout', {});
    } catch (_) {}
    await clearTokens();
  }

  // Profile
  Future<Map<String, dynamic>> getProfile() async => get('/users/me');
  Future<Map<String, dynamic>> updateDriverProfile(Map<String, dynamic> data) async => patch('/users/me/driver-profile', data);
  Future<Map<String, dynamic>> updateLocation(Map<String, dynamic> data) async => post('/users/me/location', data);

  // Rides
  Future<Map<String, dynamic>> getNearbyRides(double lat, double lng, {double radius = 10, String? vehicleType}) async {
    String endpoint = '/rides/nearby?latitude=$lat&longitude=$lng&radius=$radius';
    if (vehicleType != null) endpoint += '&vehicleType=$vehicleType';
    return get(endpoint);
  }

  // Offers
  Future<Map<String, dynamic>> submitOffer(Map<String, dynamic> data) async => post('/offers', data);
  Future<Map<String, dynamic>> getMyOffers() async => get('/offers');

  // Trips
  Future<Map<String, dynamic>> getTrips({int page = 1}) async => get('/trips?page=$page');
  Future<Map<String, dynamic>> updateTripStatus(String tripId, Map<String, dynamic> data) async => patch('/trips/$tripId/status', data);
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
