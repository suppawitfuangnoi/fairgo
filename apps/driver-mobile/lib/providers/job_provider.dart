import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class JobProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final SocketService _socket = SocketService();
  Map<String, dynamic>? _activeTrip;
  bool _isLoading = false;
  String? _error;
  List<dynamic> _nearbyRides = [];
  List<dynamic> _myOffers = [];
  List<dynamic> _tripHistory = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get nearbyRides => _nearbyRides;
  List<dynamic> get myOffers => _myOffers;
  List<dynamic> get tripHistory => _tripHistory;
  Map<String, dynamic>? get activeTrip => _activeTrip;

  Future<void> loadNearbyRides({
    double lat = 13.7563,
    double lng = 100.5018,
    double radius = 10,
    String? vehicleType,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _api.getNearbyRides(lat, lng, radius: radius, vehicleType: vehicleType);
      _nearbyRides = (result['data'] as List?) ?? [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitOffer({
    required String rideRequestId,
    required double fareAmount,
    required int estimatedPickupMinutes,
    String? message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.submitOffer({
        'rideRequestId': rideRequestId,
        'fareAmount': fareAmount,
        'estimatedPickupMinutes': estimatedPickupMinutes,
        if (message != null) 'message': message,
      });
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

  Future<void> loadMyOffers() async {
    try {
      final result = await _api.getMyOffers();
      _myOffers = (result['data'] as List?) ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadTripHistory() async {
    try {
      final result = await _api.getTrips();
      _tripHistory = (result['data']?['trips'] as List?) ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateTripStatus(String tripId, String status, {String? cancelReason}) async {
    try {
      await _api.updateTripStatus(tripId, {
        'status': status,
        if (cancelReason != null) 'cancelReason': cancelReason,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Start listening for real-time ride requests from Socket.IO
  void startListening() {
    _socket.onNewRideRequest((ride) {
      final exists = _nearbyRides.any((r) => r['id'] == ride['id']);
      if (!exists) {
        _nearbyRides.insert(0, ride);
        notifyListeners();
      }
    });

    _socket.onTripCreated((trip) {
      _activeTrip = trip;
      // Join trip room for real-time status updates
      _socket.joinTrip(trip['id']);
      notifyListeners();
    });

    _socket.onOfferRejected((_) {
      // Refresh offers list when an offer is rejected
      loadMyOffers();
    });
  }

  void stopListening() {
    _socket.off('ride:new_request');
    _socket.off('trip:created');
    _socket.off('offer:rejected');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
