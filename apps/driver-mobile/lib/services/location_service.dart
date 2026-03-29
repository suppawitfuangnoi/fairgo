import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'socket_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _subscription;
  Position? _lastPosition;
  String? _activeTripId;

  Position? get lastPosition => _lastPosition;

  LatLng get currentLatLng => _lastPosition != null
      ? LatLng(_lastPosition!.latitude, _lastPosition!.longitude)
      : const LatLng(13.7563, 100.5018); // Default: Bangkok

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;
    try {
      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return _lastPosition;
    } catch (e) {
      return null;
    }
  }

  // Start sending GPS to server via Socket.IO
  void startTracking({String? tripId, String? vehicleType}) {
    _activeTripId = tripId;
    _subscription?.cancel();
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      _lastPosition = position;
      SocketService().updateLocation(
        lat: position.latitude,
        lng: position.longitude,
        heading: position.heading,
        speed: position.speed,
        vehicleType: vehicleType,
        tripId: _activeTripId,
      );
    });
  }

  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
    _activeTripId = null;
  }

  void setActiveTrip(String? tripId) {
    _activeTripId = tripId;
  }
}
