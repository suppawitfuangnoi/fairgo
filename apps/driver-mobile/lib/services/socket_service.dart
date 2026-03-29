import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  void connect(String accessToken) {
    if (isConnected) return;

    _socket = IO.io(
      AppConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': accessToken})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      print('[Socket] Connected as driver');
      // Notify server driver is online
      _socket!.emit('driver:online', {});
    });

    _socket!.onDisconnect((_) {
      print('[Socket] Disconnected');
    });

    _socket!.onConnectError((err) {
      print('[Socket] Connect error: $err');
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.emit('driver:offline', {});
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // Emit driver GPS location
  void updateLocation({
    required double lat,
    required double lng,
    double? heading,
    double? speed,
    String? vehicleType,
    String? tripId,
  }) {
    _socket?.emit('driver:location', {
      'lat': lat,
      'lng': lng,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (tripId != null) 'tripId': tripId,
    });
  }

  // Join a trip room
  void joinTrip(String tripId) {
    _socket?.emit('trip:join', tripId);
  }

  // Listen for new ride requests nearby
  void onNewRideRequest(Function(Map<String, dynamic>) callback) {
    _socket?.on('ride:new_request', (data) {
      if (data is Map<String, dynamic>) callback(data);
    });
  }

  // Listen for trip created (offer accepted by customer)
  void onTripCreated(Function(Map<String, dynamic>) callback) {
    _socket?.on('trip:created', (data) {
      if (data is Map<String, dynamic>) callback(data);
    });
  }

  // Listen for offer rejected by customer
  void onOfferRejected(Function(Map<String, dynamic>) callback) {
    _socket?.on('offer:rejected', (data) {
      if (data is Map<String, dynamic>) callback(data);
    });
  }

  // Listen for trip status updates
  void onTripStatusUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on('trip:status_update', (data) {
      if (data is Map<String, dynamic>) callback(data);
    });
  }

  void off(String event) {
    _socket?.off(event);
  }
}
