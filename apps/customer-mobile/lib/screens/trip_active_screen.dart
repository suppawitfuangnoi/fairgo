import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/ride_provider.dart';

class TripActiveScreen extends StatelessWidget {
  const TripActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RideProvider>(
        builder: (context, ride, _) {
          final trip = ride.activeTrip;
          if (trip == null) {
            return const Center(child: Text('No active trip'));
          }

          final driver = trip['driverProfile'];
          final driverUser = driver?['user'];
          final status = trip['status'] ?? 'DRIVER_ASSIGNED';

          return SafeArea(
            child: Column(
              children: [
                // Map placeholder
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFE8F5E9),
                    child: Stack(
                      children: [
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_rounded, size: 48, color: FairGoTheme.primaryCyan),
                              SizedBox(height: 8),
                              Text('Live Trip Tracking', style: TextStyle(color: FairGoTheme.textSecondary)),
                              Text('Google Maps in Phase 2', style: TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
                              ),
                              child: const Icon(Icons.arrow_back, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Trip info bottom sheet
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4)),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status indicator
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _StatusBanner(status: status),
                          const SizedBox(height: 16),

                          // Driver info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                                child: Text(
                                  (driverUser?['name']?.toString() ?? '?').substring(0, 1),
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
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${driver?['averageRating']?.toStringAsFixed(1) ?? '0.0'}',
                                          style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Contact buttons
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: FairGoTheme.primaryCyan.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.chat_bubble_rounded, color: FairGoTheme.primaryCyan, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: FairGoTheme.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.phone_rounded, color: FairGoTheme.success, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),

                          // Fare locked
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Fare Locked',
                                style: TextStyle(fontSize: 14, color: FairGoTheme.textSecondary),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.lock_rounded, size: 16, color: FairGoTheme.success),
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
                          const SizedBox(height: 16),

                          // Route
                          Row(
                            children: [
                              Column(
                                children: [
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: FairGoTheme.primaryCyan, shape: BoxShape.circle)),
                                  Container(width: 1.5, height: 24, color: const Color(0xFFE0E0E0)),
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: FairGoTheme.danger, shape: BoxShape.circle)),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trip['pickupAddress'] ?? '',
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      trip['dropoffAddress'] ?? '',
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Safety button
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.shield_rounded, size: 18),
                            label: const Text('Safety'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FairGoTheme.danger,
                              side: const BorderSide(color: FairGoTheme.danger),
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(statusInfo.icon, color: statusInfo.color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusInfo.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: statusInfo.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'DRIVER_ASSIGNED':
        return _StatusInfo('Driver assigned', Icons.person_rounded, FairGoTheme.primaryCyan);
      case 'DRIVER_EN_ROUTE':
        return _StatusInfo('Driver is on the way', Icons.directions_car_rounded, FairGoTheme.primaryCyan);
      case 'DRIVER_ARRIVED':
        return _StatusInfo('Driver has arrived', Icons.place_rounded, FairGoTheme.success);
      case 'PICKUP_CONFIRMED':
        return _StatusInfo('Pickup confirmed', Icons.check_circle_rounded, FairGoTheme.success);
      case 'IN_PROGRESS':
        return _StatusInfo('Trip in progress', Icons.navigation_rounded, FairGoTheme.primaryCyan);
      case 'COMPLETED':
        return _StatusInfo('Trip completed', Icons.check_circle_rounded, FairGoTheme.success);
      case 'CANCELLED':
        return _StatusInfo('Trip cancelled', Icons.cancel_rounded, FairGoTheme.danger);
      default:
        return _StatusInfo(status, Icons.info_rounded, FairGoTheme.textSecondary);
    }
  }
}

class _StatusInfo {
  final String label;
  final IconData icon;
  final Color color;

  _StatusInfo(this.label, this.icon, this.color);
}
