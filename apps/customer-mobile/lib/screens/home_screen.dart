import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/ride_provider.dart';
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
    final t = context.watch<LocaleProvider>().t;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _TripsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
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
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: t.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_rounded),
              label: t.navTrips,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: t.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME TAB (Full-screen map + bottom sheet) ====================
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(13.7563, 100.5018);
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final loc = await LocationService.instance.getCurrentLocation();
    if (loc != null && mounted) {
      setState(() {
        _currentLocation = LatLng(loc.latitude, loc.longitude);
        _locationLoaded = true;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 15),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;

    return Stack(
      children: [
        // ── Full-screen GoogleMap ──
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentLocation,
            zoom: 14,
          ),
          onMapCreated: (c) {
            _mapController = c;
            if (_locationLoaded) {
              c.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation, 15));
            }
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          markers: {
            Marker(
              markerId: const MarkerId('current'),
              position: _currentLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            ),
          },
        ),

        // ── Top search pill ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final name = auth.user?['name'] ?? '';
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
                  return Row(
                    children: [
                      // Menu + search pill
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/ride-request'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: FairGoTheme.primaryCyan.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.menu_rounded,
                                    color: FairGoTheme.primaryCyan,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  t.homeWhereGoing,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFB0B0B0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Avatar
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: FairGoTheme.primaryCyan,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // ── My Location button ──
        Positioned(
          right: 16,
          bottom: 280,
          child: GestureDetector(
            onTap: _initLocation,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: FairGoTheme.primaryCyan,
                size: 22,
              ),
            ),
          ),
        ),

        // ── Bottom Sheet ──
        DraggableScrollableSheet(
          initialChildSize: 0.32,
          minChildSize: 0.15,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        margin: const EdgeInsets.only(top: 10, bottom: 16),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.homePlanRide,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: FairGoTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Pickup / Dropoff inputs
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF0F0F0)),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Route dots and connector
                                  SizedBox(
                                    width: 20,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.circle, size: 10, color: FairGoTheme.primaryCyan),
                                        Expanded(
                                          child: SizedBox(
                                            width: 2,
                                            child: CustomPaint(
                                              painter: _DashedLinePainter(),
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.location_on_rounded, size: 14, color: FairGoTheme.danger),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Input fields
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.pushNamed(context, '/ride-request'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: const Color(0xFFE8E8E8)),
                                            ),
                                            child: Text(
                                              t.homeCurrentLocation,
                                              style: const TextStyle(fontSize: 13, color: FairGoTheme.textSecondary),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => Navigator.pushNamed(context, '/ride-request'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: const Color(0xFFE8E8E8)),
                                            ),
                                            child: Text(
                                              t.homeWhereTo,
                                              style: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick shortcuts
                          Row(
                            children: [
                              _ShortcutChip(
                                icon: Icons.home_rounded,
                                label: t.homeShortcutHome,
                                onTap: () => Navigator.pushNamed(context, '/ride-request'),
                              ),
                              const SizedBox(width: 10),
                              _ShortcutChip(
                                icon: Icons.work_rounded,
                                label: t.homeShortcutWork,
                                onTap: () => Navigator.pushNamed(context, '/ride-request'),
                              ),
                              const SizedBox(width: 10),
                              _ShortcutChip(
                                icon: Icons.history_rounded,
                                label: t.homeShortcutHistory,
                                onTap: () => Navigator.pushNamed(context, '/ride-request'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Vehicle type quick launch
                          Text(
                            t.homeChooseVehicle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: FairGoTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _VehicleCard(
                                icon: Icons.local_taxi_rounded,
                                label: t.vehicleTaxi,
                                price: '${t.vehicleFromPrefix}฿35',
                                bgColor: const Color(0xFFFFF8E1),
                                iconColor: const Color(0xFFF57C00),
                                onTap: () => Navigator.pushNamed(context, '/ride-request', arguments: 'TAXI'),
                              ),
                              const SizedBox(width: 10),
                              _VehicleCard(
                                icon: Icons.two_wheeler_rounded,
                                label: t.vehicleMoto,
                                price: '${t.vehicleFromPrefix}฿25',
                                bgColor: const Color(0xFFE3F2FD),
                                iconColor: const Color(0xFF1565C0),
                                onTap: () => Navigator.pushNamed(context, '/ride-request', arguments: 'MOTORCYCLE'),
                              ),
                              const SizedBox(width: 10),
                              _VehicleCard(
                                icon: Icons.electric_rickshaw_rounded,
                                label: t.vehicleTuktuk,
                                price: '${t.vehicleFromPrefix}฿40',
                                bgColor: const Color(0xFFFCE4EC),
                                iconColor: const Color(0xFFC62828),
                                onTap: () => Navigator.pushNamed(context, '/ride-request', arguments: 'TUKTUK'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
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
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShortcutChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FBFE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FairGoTheme.primaryCyan.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: FairGoTheme.primaryCyan),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: FairGoTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String price;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.icon,
    required this.label,
    required this.price,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0F0F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: FairGoTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: const TextStyle(fontSize: 10, color: FairGoTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== TRIPS TAB ====================
class _TripsTab extends StatefulWidget {
  const _TripsTab();

  @override
  State<_TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<_TripsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RideProvider>(context, listen: false).loadTripHistory();
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
            Text(
              t.tripsTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: FairGoTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<RideProvider>(
                builder: (context, ride, _) {
                  if (ride.tripHistory.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            t.tripsEmpty,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: FairGoTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.tripsEmptyDesc,
                            style: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: ride.tripHistory.length,
                    itemBuilder: (context, index) {
                      final trip = ride.tripHistory[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF0F0F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    trip['pickupAddress'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: trip['status'] == 'COMPLETED'
                                        ? FairGoTheme.success.withValues(alpha: 0.1)
                                        : FairGoTheme.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    trip['status'] ?? '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: trip['status'] == 'COMPLETED'
                                          ? FairGoTheme.success
                                          : FairGoTheme.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '→ ${trip['dropoffAddress'] ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 13, color: FairGoTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '฿${trip['lockedFare']?.toStringAsFixed(0) ?? '0'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: FairGoTheme.primaryCyan,
                                  ),
                                ),
                                Text(
                                  trip['createdAt']?.toString().substring(0, 10) ?? '',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFBDBDBD)),
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
            return Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                  child: Text(
                    (user?['name']?.toString() ?? '?').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: FairGoTheme.primaryCyan,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?['name']?.toString() ?? 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: FairGoTheme.textPrimary,
                  ),
                ),
                Text(
                  user?['phone']?.toString() ?? '',
                  style: const TextStyle(fontSize: 14, color: FairGoTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                _ProfileMenuItem(icon: Icons.person_outline_rounded, label: t.profileEdit, onTap: () {}),
                _ProfileMenuItem(icon: Icons.account_balance_wallet_outlined, label: t.profileWallet, onTap: () {}),
                _ProfileMenuItem(icon: Icons.bookmark_border_rounded, label: t.profileSavedPlaces, onTap: () {}),
                _ProfileMenuItem(icon: Icons.local_offer_outlined, label: t.profilePromotions, onTap: () {}),
                _ProfileMenuItem(icon: Icons.headset_mic_outlined, label: t.profileSupport, onTap: () {}),
                _ProfileMenuItem(icon: Icons.settings_outlined, label: t.profileSettings, onTap: () {}),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: FairGoTheme.textPrimary, size: 22),
                  title: const Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: FairGoTheme.textPrimary,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => context.read<LocaleProvider>().toggleLocale(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: FairGoTheme.primaryCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Toggle',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: FairGoTheme.primaryCyan,
                        ),
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                const SizedBox(height: 16),
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: t.profileSignOut,
                  color: FairGoTheme.danger,
                  onTap: () {
                    auth.logout();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: color ?? FairGoTheme.textPrimary, size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: color ?? FairGoTheme.textPrimary,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
