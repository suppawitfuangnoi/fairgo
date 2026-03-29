import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/locale_provider.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _JobListTab(),
          _MyOffersTab(),
          _EarningsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          final t = localeProvider.t;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: FairGoTheme.primaryCyan,
              unselectedItemColor: const Color(0xFFB0B0B0),
              selectedLabelStyle:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.list_alt_rounded), label: t.navJobs),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.local_offer_rounded), label: t.navOffers),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.account_balance_wallet_rounded),
                    label: t.navEarnings),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.person_rounded), label: t.navProfile),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== JOB LIST TAB ====================
class _JobListTab extends StatefulWidget {
  const _JobListTab();

  @override
  State<_JobListTab> createState() => _JobListTabState();
}

class _JobListTabState extends State<_JobListTab>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng _driverLocation = const LatLng(13.7563, 100.5018);
  late String _filter;
  late AnimationController _pulseController;
  late List<String> _filters;

  @override
  void initState() {
    super.initState();
    final t = Provider.of<LocaleProvider>(context, listen: false).t;
    _filter = t.jobFilterAll;
    _filters = [t.jobFilterAll, t.jobFilterHighFare, t.jobFilterShortTrips];
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).loadNearbyRides();
      _initLocation();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final pos = await LocationService.instance.getCurrentLocation();
    if (pos != null && mounted) {
      setState(() => _driverLocation = LatLng(pos.latitude, pos.longitude));
      _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_driverLocation, 14));
    }
  }

  Set<Marker> _buildMarkers(List<dynamic> rides) {
    final markers = <Marker>{};
    markers.add(Marker(
      markerId: const MarkerId('driver'),
      position: _driverLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'You'),
    ));
    for (final ride in rides) {
      final lat = ride['pickupLatitude'];
      final lng = ride['pickupLongitude'];
      if (lat != null && lng != null) {
        markers.add(Marker(
          markerId: MarkerId(ride['id'] ?? UniqueKey().toString()),
          position:
              LatLng((lat as num).toDouble(), (lng as num).toDouble()),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(
            title: ride['pickupAddress'] ?? 'Pickup',
            snippet: '฿${ride['fareOffer']?.toStringAsFixed(0) ?? '0'}',
          ),
        ));
      }
    }
    return markers;
  }

  List<dynamic> _applyFilter(List<dynamic> rides, LocaleProvider localeProvider) {
    final t = localeProvider.t;
    if (_filter == t.jobFilterHighFare) {
      final sorted = List.from(rides);
      sorted.sort((a, b) => ((b['fareOffer'] as num?) ?? 0)
          .compareTo((a['fareOffer'] as num?) ?? 0));
      return sorted;
    } else if (_filter == t.jobFilterShortTrips) {
      final sorted = List.from(rides);
      sorted.sort((a, b) =>
          ((a['estimatedDistance'] as num?) ?? 99)
              .compareTo((b['estimatedDistance'] as num?) ?? 99));
      return sorted;
    }
    return rides;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LocaleProvider>(
      builder: (context, auth, localeProvider, _) {
        final t = localeProvider.t;
        final name = auth.user?['name'] ?? 'Driver';
        final dp = auth.user?['driverProfile'];
        final isOnline = dp?['isOnline'] ?? false;

        return SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.jobRequestsTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: FairGoTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (ctx, _) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isOnline
                                        ? FairGoTheme.success.withValues(
                                            alpha: 0.5 +
                                                _pulseController.value * 0.5)
                                        : const Color(0xFFD1D5DB),
                                  ),
                                ),
                              ),
                              Text(
                                isOnline ? t.jobOnline : t.jobOffline,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isOnline
                                      ? FairGoTheme.success
                                      : FairGoTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Online toggle
                    GestureDetector(
                      onTap: () => auth.toggleOnline(!isOnline),
                      child: Container(
                        width: 60,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? FairGoTheme.success
                              : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AnimatedAlign(
                          alignment: isOnline
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isOnline
                                  ? Icons.power_settings_new
                                  : Icons.power_off,
                              size: 14,
                              color: isOnline
                                  ? FairGoTheme.success
                                  : const Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                      child: Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: FairGoTheme.primaryCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Filter tabs ──
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: _filters.map((f) {
                    final isSelected = f == _filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? FairGoTheme.primaryCyan
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : FairGoTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Map ──
              Consumer<JobProvider>(
                builder: (context, jobs, _) {
                  return SizedBox(
                    height: 160,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _driverLocation,
                        zoom: 14,
                      ),
                      onMapCreated: (c) => _mapController = c,
                      markers: _buildMarkers(jobs.nearbyRides),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),
                  );
                },
              ),

              // ── Jobs list header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<JobProvider>(
                      builder: (context, jobs, _) => Text(
                        '${_applyFilter(jobs.nearbyRides, localeProvider).length} nearby requests',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: FairGoTheme.textSecondary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Provider.of<JobProvider>(context, listen: false)
                            .loadNearbyRides();
                        _initLocation();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FairGoTheme.primaryCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: FairGoTheme.primaryCyan, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Job cards ──
              Expanded(
                child: Consumer<JobProvider>(
                  builder: (context, jobs, _) {
                    if (jobs.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: FairGoTheme.primaryCyan));
                    }
                    final rides = _applyFilter(jobs.nearbyRides, localeProvider);
                    if (rides.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              t.jobNoRides,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FairGoTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.jobNoRidesDesc,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFFBDBDBD)),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => jobs.loadNearbyRides(),
                      color: FairGoTheme.primaryCyan,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        itemCount: rides.length,
                        itemBuilder: (context, index) {
                          return _JobCard(ride: rides[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final dynamic ride;

  const _JobCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final customerProfile = ride['customerProfile'];
    final customer = customerProfile?['user'];
    final customerName = customer?['name']?.toString() ?? 'Passenger';
    final customerRating = customerProfile?['averageRating'] ?? 5.0;
    final vehicleType = ride['vehicleType'] ?? 'TAXI';
    final vehicleIcons = {
      'TAXI': Icons.local_taxi_rounded,
      'MOTORCYCLE': Icons.two_wheeler_rounded,
      'TUKTUK': Icons.electric_rickshaw_rounded,
    };
    final fareOffer = (ride['fareOffer'] as num?)?.toDouble() ?? 0;
    final distance = ride['estimatedDistance']?.toStringAsFixed(1) ?? '0';
    final duration = ride['estimatedDuration']?.toString() ?? '0';
    final isFare = fareOffer > 150;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left urgency bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: isFare
                    ? FairGoTheme.primaryCyan
                    : FairGoTheme.primaryCyan.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Passenger avatar
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: FairGoTheme.primaryCyan
                              .withValues(alpha: 0.15),
                          child: Text(
                            customerName.substring(0, 1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: FairGoTheme.primaryCyan,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 12,
                                      color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${customerRating is double ? customerRating.toStringAsFixed(1) : customerRating} · ${context.watch<LocaleProvider>().t.jobDistance(distance)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: FairGoTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Price + vehicle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '฿${fareOffer.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: FairGoTheme.primaryCyan,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  vehicleIcons[vehicleType] ??
                                      Icons.directions_car_rounded,
                                  size: 12,
                                  color: FairGoTheme.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  context.watch<LocaleProvider>().t.jobDuration(duration),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: FairGoTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Dashed route visualization
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 18,
                          child: Column(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: FairGoTheme.primaryCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(
                                width: 2,
                                height: 22,
                                child: CustomPaint(
                                  painter: _DashedLinePainter(),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: FairGoTheme.danger, width: 2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ride['pickupAddress'] ?? '',
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                ride['dropoffAddress'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: FairGoTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Reject / Accept buttons
                    Row(
                      children: [
                        Text(
                          '${context.watch<LocaleProvider>().t.submitFareRange}: ฿${ride['fareMin']?.toStringAsFixed(0) ?? '0'} - ฿${ride['fareMax']?.toStringAsFixed(0) ?? '0'}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: FairGoTheme.textSecondary),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: FairGoTheme.textSecondary,
                            side: const BorderSide(
                                color: Color(0xFFE5E7EB)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Reject',
                              style: const TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                              context, '/submit-offer',
                              arguments: ride),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FairGoTheme.primaryCyan,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                          ),
                          child: Text(t.jobSubmitOffer,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashH = 3.0;
    const gap = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashH), paint);
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== MY OFFERS TAB ====================
class _MyOffersTab extends StatefulWidget {
  const _MyOffersTab();

  @override
  State<_MyOffersTab> createState() => _MyOffersTabState();
}

class _MyOffersTabState extends State<_MyOffersTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).loadMyOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.offersTitle,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<JobProvider>(
                builder: (context, jobs, _) {
                  if (jobs.myOffers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer_rounded,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(t.offersEmpty,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: FairGoTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Text(t.offersEmptyDesc,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFFBDBDBD))),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: jobs.myOffers.length,
                    itemBuilder: (context, index) {
                      final offer = jobs.myOffers[index];
                      final statusColors = {
                        'PENDING': FairGoTheme.warning,
                        'ACCEPTED': FairGoTheme.success,
                        'REJECTED': FairGoTheme.danger,
                      };
                      final statusMap = {
                        'PENDING': t.offerStatusPending,
                        'ACCEPTED': t.offerStatusAccepted,
                        'REJECTED': t.offerStatusRejected,
                      };
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFF0F0F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer['rideRequest']
                                            ?['pickupAddress'] ??
                                        '',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '→ ${offer['rideRequest']?['dropoffAddress'] ?? ''}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: FairGoTheme.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '฿${offer['fareAmount']?.toStringAsFixed(0) ?? '0'}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: FairGoTheme.primaryCyan),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (statusColors[offer['status']] ??
                                            FairGoTheme.textSecondary)
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusMap[offer['status']] ?? offer['status'] ?? '',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: statusColors[
                                                offer['status']] ??
                                            FairGoTheme.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== EARNINGS TAB ====================
class _EarningsTab extends StatefulWidget {
  const _EarningsTab();

  @override
  State<_EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends State<_EarningsTab> {
  bool _isWeekly = true;

  final List<_EarningsDay> _weeklyData = [
    _EarningsDay('Mon', 0.45),
    _EarningsDay('Tue', 0.62),
    _EarningsDay('Wed', 0.30),
    _EarningsDay('Thu', 0.78),
    _EarningsDay('Fri', 0.90),
    _EarningsDay('Sat', 0.55),
    _EarningsDay('Sun', 0.40),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;

    return SafeArea(
      child: SingleChildScrollView(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final name = auth.user?['name'] ?? 'Driver';
            final dp = auth.user?['driverProfile'];
            final totalTrips = dp?['totalTrips'] ?? 0;
            final rating = dp?['averageRating']?.toStringAsFixed(1) ?? '0.0';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 12,
                                color: FairGoTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: FairGoTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                        child: Text(
                          name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: FairGoTheme.primaryCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Balance card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: FairGoTheme.primaryCyan
                                  .withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: FairGoTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '฿0.00',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: FairGoTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 16),
                                label: const Text('Withdraw Funds'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FairGoTheme.primaryCyan,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Earnings chart ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t.earningsTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: FairGoTheme.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: ['Weekly', 'Daily'].map((label) {
                                final sel = (label == 'Weekly') == _isWeekly;
                                return GestureDetector(
                                  onTap: () => setState(
                                      () => _isWeekly = label == 'Weekly'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: sel
                                            ? FairGoTheme.textPrimary
                                            : FairGoTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bar chart
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: const Color(0xFFF0F0F0)),
                        ),
                        child: Column(
                          children: [
                            // Stats row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        t.earningsTripsLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: FairGoTheme.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        '$totalTrips',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: FairGoTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    width: 1,
                                    height: 32,
                                    color: const Color(0xFFF0F0F0)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        t.earningsAvgLabel,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: FairGoTheme.textSecondary,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.star_rounded,
                                              size: 14,
                                              color: Color(0xFFF59E0B)),
                                          const SizedBox(width: 2),
                                          Text(
                                            rating,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: FairGoTheme.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            // Bar chart
                            SizedBox(
                              height: 120,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: _weeklyData.map((d) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  height: 100 * d.heightRatio,
                                                  decoration: BoxDecoration(
                                                    color: FairGoTheme
                                                        .primaryCyan,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            d.label,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: FairGoTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EarningsDay {
  final String label;
  final double heightRatio;

  const _EarningsDay(this.label, this.heightRatio);
}

// ==================== PROFILE TAB ====================
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.user;
            final dp = user?['driverProfile'];
            return Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                  child: Text(
                    (user?['name']?.toString() ?? '?')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: FairGoTheme.primaryCyan),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?['name']?.toString() ?? 'Driver',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?['phone']?.toString() ?? '',
                  style: const TextStyle(
                      fontSize: 14, color: FairGoTheme.textSecondary),
                ),
                if (dp?['isVerified'] == true)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: FairGoTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 14, color: FairGoTheme.success),
                        SizedBox(width: 4),
                        Text(
                          'Verified Driver',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: FairGoTheme.success),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                _MenuItem(
                    icon: Icons.person_outline,
                    label: t.profileVehicleInfo,
                    onTap: () {}),
                _MenuItem(
                    icon: Icons.description_outlined,
                    label: t.profileDocuments,
                    onTap: () {}),
                _MenuItem(
                    icon: Icons.headset_mic_outlined,
                    label: t.profileSupport,
                    onTap: () {}),
                _MenuItem(
                    icon: Icons.settings_outlined,
                    label: t.profileSettings,
                    onTap: () {}),
                const SizedBox(height: 8),
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: t.profileSignOut,
                  color: FairGoTheme.danger,
                  onTap: () {
                    auth.logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem(
      {required this.icon,
      required this.label,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading:
            Icon(icon, color: color ?? FairGoTheme.textPrimary, size: 22),
        title: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color ?? FairGoTheme.textPrimary)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: Colors.grey[300], size: 20),
        onTap: onTap,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
