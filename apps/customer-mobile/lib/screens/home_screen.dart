import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/ride_provider.dart';

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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
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
          unselectedItemColor: FairGoTheme.textSecondary,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final name = auth.user?['name'] ?? 'there';
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $name',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: FairGoTheme.textPrimary,
                              ),
                            ),
                            const Text(
                              'Where do you want to go?',
                              style: TextStyle(
                                fontSize: 14,
                                color: FairGoTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.notifications_rounded,
                          color: FairGoTheme.primaryCyan,
                          size: 22,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Map placeholder with search
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_rounded, size: 48, color: FairGoTheme.primaryCyan),
                          SizedBox(height: 8),
                          Text(
                            'Map View',
                            style: TextStyle(
                              color: FairGoTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Google Maps integration in Phase 2',
                            style: TextStyle(
                              color: Color(0xFFBDBDBD),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Current location button
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: FairGoTheme.primaryCyan,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Where to? search bar
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/ride-request'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: FairGoTheme.primaryCyan),
                      SizedBox(width: 12),
                      Text(
                        'Where to?',
                        style: TextStyle(
                          fontSize: 16,
                          color: FairGoTheme.textSecondary,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFBDBDBD)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Vehicle types
              const Text(
                'Choose Vehicle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: FairGoTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _VehicleCard(
                    icon: Icons.local_taxi_rounded,
                    label: 'Taxi',
                    price: 'From ฿35',
                    color: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFF57C00),
                    onTap: () => Navigator.pushNamed(context, '/ride-request', arguments: 'TAXI'),
                  ),
                  const SizedBox(width: 12),
                  _VehicleCard(
                    icon: Icons.two_wheeler_rounded,
                    label: 'Motorcycle',
                    price: 'From ฿25',
                    color: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF1565C0),
                    onTap: () => Navigator.pushNamed(context, '/ride-request', arguments: 'MOTORCYCLE'),
                  ),
                  const SizedBox(width: 12),
                  _VehicleCard(
                    icon: Icons.electric_rickshaw_rounded,
                    label: 'Tuk-Tuk',
                    price: 'From ฿40',
                    color: const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFC62828),
                    onTap: () => Navigator.pushNamed(context, '/ride-request', arguments: 'TUKTUK'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Saved places
              const Text(
                'Saved Places',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: FairGoTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _SavedPlaceItem(
                icon: Icons.home_rounded,
                label: 'Home',
                subtitle: 'Set your home address',
                color: FairGoTheme.primaryCyan,
                onTap: () => Navigator.pushNamed(context, '/ride-request'),
              ),
              const SizedBox(height: 8),
              _SavedPlaceItem(
                icon: Icons.work_rounded,
                label: 'Work',
                subtitle: 'Set your work address',
                color: FairGoTheme.warning,
                onTap: () => Navigator.pushNamed(context, '/ride-request'),
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
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.icon,
    required this.label,
    required this.price,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FairGoTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: const TextStyle(fontSize: 11, color: FairGoTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedPlaceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SavedPlaceItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FairGoTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDBDBD), size: 20),
          ],
        ),
      ),
    );
  }
}

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip History',
              style: TextStyle(
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
                          const Text(
                            'No trips yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: FairGoTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Your trip history will appear here',
                            style: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
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
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
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

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
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
                _ProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Saved Places',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Promotions',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.headset_mic_outlined,
                  label: 'Support',
                  onTap: () {},
                ),
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
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
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey[300],
          size: 20,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
