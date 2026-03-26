import 'dart:async';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Poll for offers every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      Provider.of<RideProvider>(context, listen: false).refreshActiveRide();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: const Text('Finding Drivers'),
        backgroundColor: FairGoTheme.primaryCyan,
        actions: [
          TextButton(
            onPressed: () async {
              final ride = Provider.of<RideProvider>(context, listen: false);
              await ride.cancelRide();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              }
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Consumer<RideProvider>(
        builder: (context, ride, _) {
          final activeRide = ride.activeRide;
          final offers = ride.offers;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ride info card
                if (activeRide != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 10, color: FairGoTheme.primaryCyan),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activeRide['pickupAddress'] ?? '',
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Container(width: 2, height: 16, color: const Color(0xFFE0E0E0)),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 10, color: FairGoTheme.danger),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activeRide['dropoffAddress'] ?? '',
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your offer: ฿${activeRide['fareOffer']}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: FairGoTheme.primaryCyan,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: FairGoTheme.primaryCyan.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activeRide['vehicleType'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: FairGoTheme.primaryCyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Searching animation
                if (offers.isEmpty) ...[
                  Center(
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 120 + (_pulseController.value * 30),
                              height: 120 + (_pulseController.value * 30),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: FairGoTheme.primaryCyan.withValues(
                                  alpha: 0.15 * (1 - _pulseController.value),
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: FairGoTheme.primaryCyan.withValues(alpha: 0.2),
                                  ),
                                  child: const Icon(
                                    Icons.search_rounded,
                                    size: 36,
                                    color: FairGoTheme.primaryCyan,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Searching for drivers...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FairGoTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Nearby drivers will see your request and can submit offers',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: FairGoTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Driver offers
                  Text(
                    'Driver Offers (${offers.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: FairGoTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...offers.where((o) => o['status'] == 'PENDING').map((offer) {
                    final driver = offer['driverProfile'];
                    final driverUser = driver?['user'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF0F0F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                                child: Text(
                                  (driverUser?['name']?.toString() ?? '?').substring(0, 1),
                                  style: const TextStyle(
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
                                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${driver?['averageRating']?.toStringAsFixed(1) ?? '0.0'} · ${driver?['totalTrips'] ?? 0} trips',
                                          style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary),
                                        ),
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: FairGoTheme.primaryCyan,
                                    ),
                                  ),
                                  Text(
                                    '${offer['estimatedPickupMinutes']} min away',
                                    style: const TextStyle(fontSize: 11, color: FairGoTheme.textSecondary),
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
                                  onPressed: () => _rejectOffer(offer['id']),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: FairGoTheme.textSecondary,
                                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Decline'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _acceptOffer(offer['id']),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Accept'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
