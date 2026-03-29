import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/ride_provider.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with SingleTickerProviderStateMixin {
  Timer? _pollTimer;
  late AnimationController _pulseController;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      Provider.of<RideProvider>(context, listen: false).refreshActiveRide();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(Map<String, dynamic>? activeRide) {
    if (activeRide == null) return {};
    final markers = <Marker>{};
    final pickupLat = (activeRide['pickupLatitude'] as num?)?.toDouble();
    final pickupLng = (activeRide['pickupLongitude'] as num?)?.toDouble();
    final dropoffLat = (activeRide['dropoffLatitude'] as num?)?.toDouble();
    final dropoffLng = (activeRide['dropoffLongitude'] as num?)?.toDouble();
    if (pickupLat != null && pickupLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickupLat, pickupLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(title: 'จุดรับ', snippet: activeRide['pickupAddress'] ?? ''),
      ));
    }
    if (dropoffLat != null && dropoffLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(dropoffLat, dropoffLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'จุดส่ง', snippet: activeRide['dropoffAddress'] ?? ''),
      ));
    }
    return markers;
  }

  void _fitMapBounds(Map<String, dynamic>? activeRide) {
    if (activeRide == null) return;
    final pickupLat = (activeRide['pickupLatitude'] as num?)?.toDouble();
    final pickupLng = (activeRide['pickupLongitude'] as num?)?.toDouble();
    final dropoffLat = (activeRide['dropoffLatitude'] as num?)?.toDouble();
    final dropoffLng = (activeRide['dropoffLongitude'] as num?)?.toDouble();
    if (pickupLat == null || dropoffLat == null) return;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            pickupLat < dropoffLat ? pickupLat - 0.005 : dropoffLat - 0.005,
            pickupLng! < dropoffLng! ? pickupLng - 0.005 : dropoffLng - 0.005,
          ),
          northeast: LatLng(
            pickupLat > dropoffLat ? pickupLat + 0.005 : dropoffLat + 0.005,
            pickupLng > dropoffLng ? pickupLng + 0.005 : dropoffLng + 0.005,
          ),
        ),
        60,
      ),
    );
  }

  Future<void> _acceptOffer(String offerId) async {
    final ride = Provider.of<RideProvider>(context, listen: false);
    final success = await ride.respondToOffer(offerId, 'ACCEPT');
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/trip-active');
    }
  }

  Future<void> _rejectOffer(String offerId) async {
    final ride = Provider.of<RideProvider>(context, listen: false);
    await ride.respondToOffer(offerId, 'REJECT');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RideProvider>(
        builder: (context, ride, _) {
          final activeRide = ride.activeRide;
          final offers =
              ride.offers.where((o) => o['status'] == 'PENDING').toList();
          final fareOffer = activeRide?['fareOffer'];

          return Stack(
            children: [
              // ── Full-screen map ──
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    (activeRide?['pickupLatitude'] as num?)?.toDouble() ?? 13.7563,
                    (activeRide?['pickupLongitude'] as num?)?.toDouble() ?? 100.5018,
                  ),
                  zoom: 13,
                ),
                markers: _buildMarkers(activeRide),
                onMapCreated: (c) {
                  _mapController = c;
                  _fitMapBounds(activeRide);
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
              ),

              // ── Top pill: "Finding drivers..." + X ──
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
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (ctx, _) => Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: FairGoTheme.primaryCyan
                                          .withValues(alpha: 0.3 + _pulseController.value * 0.7),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    offers.isEmpty
                                        ? 'กำลังค้นหาคนขับ...'
                                        : 'พบคนขับ ${offers.length} คน',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: FairGoTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            final rideP = Provider.of<RideProvider>(context, listen: false);
                            await rideP.cancelRide();
                            if (mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false);
                            }
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: FairGoTheme.textSecondary, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom sheet ──
              DraggableScrollableSheet(
                initialChildSize: offers.isEmpty ? 0.22 : 0.52,
                minChildSize: 0.15,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return Container(
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
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 14),
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sheet title + tag
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        offers.isEmpty
                                            ? 'กำลังค้นหา...'
                                            : 'พบคนขับ ${offers.length} คน',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: FairGoTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: FairGoTheme.primaryCyan
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Fair Price',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: FairGoTheme.primaryCyan,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (offers.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  const Text(
                                    'คนขับเลือกคุณ เพราะราคานี้แฟร์',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: FairGoTheme.textSecondary,
                                    ),
                                  ),
                                ],

                                // Your offer summary
                                if (activeRide != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FBFE),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: FairGoTheme.primaryCyan
                                              .withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.local_taxi_rounded,
                                            color: FairGoTheme.primaryCyan,
                                            size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'ราคาที่เสนอ: ฿${activeRide['fareOffer']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: FairGoTheme.primaryCyan,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          activeRide['vehicleType'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: FairGoTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                if (offers.isEmpty) ...[
                                  const SizedBox(height: 30),
                                  Center(
                                    child: Column(
                                      children: [
                                        AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            return Container(
                                              width: 90 +
                                                  (_pulseController.value * 20),
                                              height: 90 +
                                                  (_pulseController.value * 20),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: FairGoTheme.primaryCyan
                                                    .withValues(
                                                  alpha: 0.1 *
                                                      (1 -
                                                          _pulseController
                                                              .value),
                                                ),
                                              ),
                                              child: Center(
                                                child: Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: FairGoTheme
                                                        .primaryCyan
                                                        .withValues(alpha: 0.15),
                                                  ),
                                                  child: const Icon(
                                                    Icons.search_rounded,
                                                    size: 28,
                                                    color:
                                                        FairGoTheme.primaryCyan,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'กำลังค้นหาคนขับ...',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: FairGoTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'คนขับบริเวณใกล้เคียงจะเห็นคำขอของคุณ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: FairGoTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ] else ...[
                                  const SizedBox(height: 16),
                                  // Driver offer cards
                                  ...offers.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final offer = entry.value;
                                    final isBest = index == 0;
                                    return _DriverOfferCard(
                                      offer: offer,
                                      isBestMatch: isBest,
                                      onAccept: () =>
                                          _acceptOffer(offer['id']),
                                      onDecline: () =>
                                          _rejectOffer(offer['id']),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DriverOfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final bool isBestMatch;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _DriverOfferCard({
    required this.offer,
    required this.isBestMatch,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final driver = offer['driverProfile'];
    final driverUser = driver?['user'];
    final vehicles = driver?['vehicles'] as List?;
    final vehicle = vehicles?.isNotEmpty == true ? vehicles![0] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBestMatch
              ? FairGoTheme.primaryCyan.withValues(alpha: 0.4)
              : const Color(0xFFF0F0F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                        child: Text(
                          (driverUser?['name']?.toString() ?? '?')
                              .substring(0, 1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: FairGoTheme.primaryCyan,
                            fontSize: 16,
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
                                    size: 13, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 2),
                                Text(
                                  '${driver?['averageRating']?.toStringAsFixed(1) ?? '0.0'} · ${driver?['totalTrips'] ?? 0} เที่ยว',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: FairGoTheme.textSecondary),
                                ),
                                if (vehicle != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    vehicle['plateNumber'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: FairGoTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '฿${offer['fareAmount']}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: FairGoTheme.primaryCyan,
                            ),
                          ),
                          Text(
                            'อีก ${offer['estimatedPickupMinutes']} นาที',
                            style: const TextStyle(
                                fontSize: 11,
                                color: FairGoTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (offer['message'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${offer['message']}"',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: FairGoTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDecline,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: FairGoTheme.textSecondary,
                            side:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('ปฏิเสธ',
                              style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FairGoTheme.primaryCyan,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                          ),
                          child: const Text('รับ',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // BEST MATCH ribbon
            if (isBestMatch)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    color: FairGoTheme.primaryCyan,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'BEST MATCH',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
