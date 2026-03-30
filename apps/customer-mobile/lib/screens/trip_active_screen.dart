import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/theme.dart';
import '../providers/ride_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_translations.dart';
import '../services/socket_service.dart';

class TripActiveScreen extends StatefulWidget {
  const TripActiveScreen({super.key});

  @override
  State<TripActiveScreen> createState() => _TripActiveScreenState();
}

class _TripActiveScreenState extends State<TripActiveScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _driverLocation;
  Set<Marker> _markers = {};
  Timer? _pollTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    SocketService().onDriverLocation((data) {
      final lat = (data['lat'] as num).toDouble();
      final lng = (data['lng'] as num).toDouble();
      final pos = LatLng(lat, lng);
      if (mounted) {
        setState(() {
          _driverLocation = pos;
          _markers = {
            Marker(
              markerId: const MarkerId('driver'),
              position: pos,
              infoWindow: const InfoWindow(title: 'คนขับ'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          };
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
      }
    });

    // Poll trip status every 10 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      Provider.of<RideProvider>(context, listen: false).refreshActiveRide();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseController.dispose();
    SocketService().off('trip:driver:location');
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;

    return Scaffold(
      body: Consumer<RideProvider>(
        builder: (context, ride, _) {
          final trip = ride.activeTrip;
          if (trip == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final driver = trip['driverProfile'];
          final driverUser = driver?['user'];
          final status = trip['status'] ?? 'DRIVER_ASSIGNED';
          final vehicles = driver?['vehicles'] as List?;
          final vehicle = vehicles?.isNotEmpty == true ? vehicles![0] : null;

          final pickupLat = (trip['pickupLatitude'] as num?)?.toDouble() ?? 13.7563;
          final pickupLng = (trip['pickupLongitude'] as num?)?.toDouble() ?? 100.5018;
          final dropoffLat = (trip['dropoffLatitude'] as num?)?.toDouble() ?? 13.7563;
          final dropoffLng = (trip['dropoffLongitude'] as num?)?.toDouble() ?? 100.5018;

          // Check if trip completed → navigate to summary
          if (status == 'COMPLETED') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/trip-summary',
                    arguments: trip);
              }
            });
          }

          return Stack(
            children: [
              // ── Full-screen GoogleMap ──
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(pickupLat, pickupLng),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: LatLng(pickupLat, pickupLng),
                    infoWindow: InfoWindow(title: t.tripPickupMarker),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueCyan),
                  ),
                  Marker(
                    markerId: const MarkerId('dropoff'),
                    position: LatLng(dropoffLat, dropoffLng),
                    infoWindow: InfoWindow(title: t.tripDropoffMarker),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                  ..._markers,
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: (c) => _mapController = c,
              ),

              // ── Top status pill ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF0F0F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: FairGoTheme.primaryCyan.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.near_me_rounded,
                                      color: FairGoTheme.primaryCyan, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Status',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: FairGoTheme.textSecondary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        _statusLabel(status, t),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: FairGoTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // SOS / Shield button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FairGoTheme.danger,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: FairGoTheme.danger.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.shield_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── "Driver is nearby!" badge ──
              if (status == 'DRIVER_ARRIVED')
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: FairGoTheme.success,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: FairGoTheme.success.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            t.tripDriverNearby,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Bottom card ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 24,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Driver info row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                            child: Text(
                              (driverUser?['name']?.toString() ?? '?')
                                  .substring(0, 1),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: FairGoTheme.primaryCyan,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driverUser?['name']?.toString() ?? 'Driver',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 13,
                                        color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 2),
                                    Text(
                                      driver?['averageRating']
                                              ?.toStringAsFixed(1) ??
                                          '0.0',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: FairGoTheme.textSecondary),
                                    ),
                                    if (vehicle != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        vehicle['plateNumber'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: FairGoTheme.textPrimary),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Fare
                          Row(
                            children: [
                              const Icon(Icons.lock_rounded,
                                  size: 14, color: FairGoTheme.success),
                              const SizedBox(width: 4),
                              Text(
                                '฿${trip['lockedFare']?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: FairGoTheme.primaryCyan,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Locked price info box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: FairGoTheme.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded,
                                size: 14,
                                color: FairGoTheme.success),
                            const SizedBox(width: 6),
                            Text(
                              t.tripPriceLocked,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: FairGoTheme.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Chat + Call buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.chat_bubble_rounded,
                                  size: 16),
                              label: Text(t.tripChat),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: FairGoTheme.primaryCyan,
                                side: BorderSide(
                                    color: FairGoTheme.primaryCyan
                                        .withValues(alpha: 0.4)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.phone_rounded, size: 16),
                              label: Text(t.tripCallDriver),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FairGoTheme.primaryCyan,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusLabel(String status, AppTranslations t) {
    switch (status) {
      case 'DRIVER_ASSIGNED':
        return t.tripStatusAssigned;
      case 'DRIVER_EN_ROUTE':
        return t.tripStatusEnRoute;
      case 'DRIVER_ARRIVED':
        return t.tripStatusArrived;
      case 'PICKUP_CONFIRMED':
        return t.tripStatusPickupConfirmed;
      case 'IN_PROGRESS':
        return t.tripStatusInProgress;
      default:
        return status.replaceAll('_', ' ');
    }
  }
}
