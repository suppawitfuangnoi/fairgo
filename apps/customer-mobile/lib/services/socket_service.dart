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
      print('[Socket] Connected as customer');
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
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // Join a trip room to receive real-time updates
  void joinTrip(String tripId) {
    _socket?.emit('trip:join', tripId);
  }

  void leaveTrip(String tripId) {
    _socket?.emit('trip:leave', tripId);
  }

  // Listen for new offer from driver
  void onOfferNew(Function(Map<String, dynamic>) callback) {
    _socket?.on('offer:new', (data) {
      if (data is Map<String, dynamic>) callback(data);
    });
  }

  // Listen for trip status updates (driver en route, arrived, etc.)
  void onTripStatusUpdate(Function(Map<String, dynamic>) callback) {
    _socket?.on('trip:status_update', (data) {
      if (data is Map<String, dynamic>) callback(data);
    });
  }

  // Listen for driver location updates during trip
  void onDriverLocation(Function(Map<String, dynamic>) callback) {
    _socket?.on('trip:driver:location', (data) {
      if (data is Map<String, dynamic>) callback(data);
    });
  }

  void off(String event) {
    _socket?.off(event);
  }
}
