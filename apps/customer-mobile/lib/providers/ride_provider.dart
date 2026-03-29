import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class RideProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final SocketService _socket = SocketService();
  bool _isLoading = false;
  String? _error;

  // Fare estimate
  Map<String, dynamic>? _fareEstimate;
  // Active ride request
  Map<String, dynamic>? _activeRide;
  // Offers for active ride
  List<dynamic> _offers = [];
  // Active trip
  Map<String, dynamic>? _activeTrip;
  // Trip history
  List<dynamic> _tripHistory = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get fareEstimate => _fareEstimate;
  Map<String, dynamic>? get activeRide => _activeRide;
  List<dynamic> get offers => _offers;
  Map<String, dynamic>? get activeTrip => _activeTrip;
  List<dynamic> get tripHistory => _tripHistory;

  Future<bool> getFareEstimate({
    required String vehicleType,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.getFareEstimate({
        'vehicleType': vehicleType,
        'pickupLatitude': pickupLat,
        'pickupLongitude': pickupLng,
        'dropoffLatitude': dropoffLat,
        'dropoffLongitude': dropoffLng,
      });
      _fareEstimate = result['data'];
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

  Future<bool> createRideRequest({
    required String vehicleType,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    required double fareMin,
    required double fareMax,
    required double fareOffer,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.createRideRequest({
        'vehicleType': vehicleType,
        'pickupLatitude': pickupLat,
        'pickupLongitude': pickupLng,
        'pickupAddress': pickupAddress,
        'dropoffLatitude': dropoffLat,
        'dropoffLongitude': dropoffLng,
        'dropoffAddress': dropoffAddress,
        'fareMin': fareMin,
        'fareMax': fareMax,
        'fareOffer': fareOffer,
      });
      _activeRide = result['data'];
      // Subscribe to real-time offer notifications
      _listenForOffers();
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

  Future<void> refreshActiveRide() async {
    if (_activeRide == null) return;
    try {
      final result = await _api.getRideById(_activeRide!['id']);
      _activeRide = result['data'];
      _offers = (_activeRide!['offers'] as List?) ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> respondToOffer(String offerId, String action) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _api.respondToOffer(offerId, action);
      if (action == 'ACCEPT' && result['data'] != null) {
        _activeTrip = result['data'];
        _activeRide = null;
      }
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

  Future<void> cancelRide() async {
    if (_activeRide == null) return;
    try {
      await _api.cancelRide(_activeRide!['id']);
      _activeRide = null;
      _offers = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadTripHistory() async {
    try {
      final result = await _api.getTrips();
      _tripHistory = (result['data']?['trips'] as List?) ?? [];
      notifyListeners();
    } catch (_) {}
  }

  // Listen for real-time offer notifications from Socket.IO
  void _listenForOffers() {
    _socket.onOfferNew((offer) {
      // Add new offer if not already in list
      final exists = _offers.any((o) => o['id'] == offer['id']);
      if (!exists) {
        _offers.add(offer);
        notifyListeners();
      }
    });
  }

  // Start listening for trip status updates after trip is created
  void listenToTrip(String tripId) {
    _socket.joinTrip(tripId);
    _socket.onTripStatusUpdate((trip) {
      _activeTrip = trip;
      notifyListeners();
    });
  }

  void stopListeningToTrip(String tripId) {
    _socket.leaveTrip(tripId);
    _socket.off('trip:status_update');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> submitRating({
    required String tripId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _api.post('/api/v1/rides/$tripId/rate', {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void reset() {
    _socket.off('offer:new');
    _fareEstimate = null;
    _activeRide = null;
    _offers = [];
    _activeTrip = null;
    notifyListeners();
  }
}
