import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';

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
          _JobListTab(),
          _MyOffersTab(),
          _EarningsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: FairGoTheme.primaryCyan,
          unselectedItemColor: FairGoTheme.textSecondary,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.local_offer_rounded), label: 'My Offers'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Earnings'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
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

class _JobListTabState extends State<_JobListTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).loadNearbyRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header with online toggle
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            color: Colors.white,
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final driverProfile = auth.user?['driverProfile'];
                final isOnline = driverProfile?['isOnline'] ?? false;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${auth.user?['name'] ?? 'Driver'}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: FairGoTheme.textPrimary),
                              ),
                              Text(
                                isOnline ? 'You are online' : 'You are offline',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isOnline ? FairGoTheme.success : FairGoTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Online toggle
                        GestureDetector(
                          onTap: () => auth.toggleOnline(!isOnline),
                          child: Container(
                            width: 64,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isOnline ? FairGoTheme.success : const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: AnimatedAlign(
                              alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isOnline ? Icons.power_settings_new : Icons.power_off,
                                  size: 16,
                                  color: isOnline ? FairGoTheme.success : const Color(0xFFBDBDBD),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Quick stats
                    Row(
                      children: [
                        _QuickStat(label: 'Rating', value: '${driverProfile?['averageRating']?.toStringAsFixed(1) ?? '0.0'}', icon: Icons.star_rounded),
                        const SizedBox(width: 10),
                        _QuickStat(label: 'Trips', value: '${driverProfile?['totalTrips'] ?? 0}', icon: Icons.route_rounded),
                        const SizedBox(width: 10),
                        _QuickStat(label: 'Accept', value: '${((driverProfile?['acceptanceRate'] ?? 0) * 100).toStringAsFixed(0)}%', icon: Icons.check_circle_rounded),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          // Nearby rides header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nearby Ride Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                GestureDetector(
                  onTap: () => Provider.of<JobProvider>(context, listen: false).loadNearbyRides(),
                  child: const Icon(Icons.refresh_rounded, color: FairGoTheme.primaryCyan, size: 22),
                ),
              ],
            ),
          ),
          // Ride list
          Expanded(
            child: Consumer<JobProvider>(
              builder: (context, jobs, _) {
                if (jobs.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: FairGoTheme.primaryCyan));
                }
                if (jobs.nearbyRides.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No nearby rides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: FairGoTheme.textSecondary)),
                        const SizedBox(height: 4),
                        const Text('New requests will appear here', style: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD))),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => jobs.loadNearbyRides(),
                  color: FairGoTheme.primaryCyan,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: jobs.nearbyRides.length,
                    itemBuilder: (context, index) {
                      final ride = jobs.nearbyRides[index];
                      return _RideRequestCard(ride: ride);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _QuickStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: FairGoTheme.primaryCyan.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: FairGoTheme.primaryCyan),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: FairGoTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _RideRequestCard extends StatelessWidget {
  final dynamic ride;

  const _RideRequestCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final customerName = ride['customerProfile']?['user']?['name'] ?? 'Passenger';
    final vehicleType = ride['vehicleType'] ?? 'TAXI';
    final vehicleIcons = {'TAXI': '🚕', 'MOTORCYCLE': '🏍️', 'TUKTUK': '🛺'};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              CircleAvatar(
                radius: 18,
                backgroundColor: FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                child: Text(customerName.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: FairGoTheme.primaryCyan, fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${vehicleIcons[vehicleType] ?? ''} $vehicleType', style: const TextStyle(fontSize: 11, color: FairGoTheme.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '฿${ride['fareOffer']?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FairGoTheme.primaryCyan),
                  ),
                  Text(
                    '${ride['estimatedDistance']?.toStringAsFixed(1) ?? '0'} km',
                    style: const TextStyle(fontSize: 11, color: FairGoTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: FairGoTheme.primaryCyan, shape: BoxShape.circle)),
                  Container(width: 1.5, height: 20, color: const Color(0xFFE0E0E0)),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: FairGoTheme.danger, shape: BoxShape.circle)),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ride['pickupAddress'] ?? '', style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Text(ride['dropoffAddress'] ?? '', style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Range: ฿${ride['fareMin']?.toStringAsFixed(0) ?? '0'} - ฿${ride['fareMax']?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(fontSize: 11, color: FairGoTheme.textSecondary),
              ),
              const Spacer(),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/submit-offer', arguments: ride),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Submit Offer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Offers', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<JobProvider>(
                builder: (context, jobs, _) {
                  if (jobs.myOffers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('No offers yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: FairGoTheme.textSecondary)),
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF0F0F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(offer['rideRequest']?['pickupAddress'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('→ ${offer['rideRequest']?['dropoffAddress'] ?? ''}', style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('฿${offer['fareAmount']?.toStringAsFixed(0) ?? '0'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: FairGoTheme.primaryCyan)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (statusColors[offer['status']] ?? FairGoTheme.textSecondary).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    offer['status'] ?? '',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColors[offer['status']] ?? FairGoTheme.textSecondary),
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
class _EarningsTab extends StatelessWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Earnings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [FairGoTheme.primaryCyan, FairGoTheme.primaryDark]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text("Today's Earnings", style: TextStyle(fontSize: 14, color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('฿0.00', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('0 trips completed', style: TextStyle(fontSize: 13, color: Colors.white60)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: const Column(
                children: [
                  Text('Detailed earnings dashboard will be available in Phase 2', style: TextStyle(fontSize: 13, color: FairGoTheme.textSecondary)),
                ],
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
                  backgroundColor: FairGoTheme.darkBg,
                  child: Text(
                    (user?['name']?.toString() ?? '?').substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: FairGoTheme.primaryCyan),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?['name']?.toString() ?? 'Driver', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(user?['phone']?.toString() ?? '', style: const TextStyle(fontSize: 14, color: FairGoTheme.textSecondary)),
                if (dp?['isVerified'] == true)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: FairGoTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: FairGoTheme.success),
                        SizedBox(width: 4),
                        Text('Verified Driver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: FairGoTheme.success)),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                _MenuItem(icon: Icons.person_outline, label: 'Edit Profile', onTap: () {}),
                _MenuItem(icon: Icons.directions_car_outlined, label: 'My Vehicles', onTap: () {}),
                _MenuItem(icon: Icons.description_outlined, label: 'Documents', onTap: () {}),
                _MenuItem(icon: Icons.account_balance_wallet_outlined, label: 'Wallet', onTap: () {}),
                _MenuItem(icon: Icons.headset_mic_outlined, label: 'Support', onTap: () {}),
                _MenuItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () {}),
                const SizedBox(height: 8),
                _MenuItem(
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: color ?? FairGoTheme.textPrimary, size: 22),
        title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color ?? FairGoTheme.textPrimary)),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
