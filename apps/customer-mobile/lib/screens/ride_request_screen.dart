import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/ride_provider.dart';
import '../providers/locale_provider.dart';
import '../services/location_service.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController(text: 'ICONSIAM, Charoen Nakhon Rd');
  String _vehicleType = 'TAXI';
  double _fareOffer = 165;
  bool _estimateLoaded = false;
  static const double _minFare = 80;
  static const double _maxFare = 250;

  double _pickupLat = 13.7563;
  double _pickupLng = 100.5018;
  double _dropoffLat = 13.7262;
  double _dropoffLng = 100.5098;

  GoogleMapController? _mapController;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) setState(() => _vehicleType = args);
      _initLocation();
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final t = Provider.of<LocaleProvider>(context, listen: false).t;
    final pos = await LocationService().getCurrentLocation();
    if (pos != null && mounted) {
      setState(() {
        _pickupLat = pos.latitude;
        _pickupLng = pos.longitude;
        _pickupController.text = t.rideCurrentLocation;
        _loadingLocation = false;
      });
      _animateMap();
      await _loadFareEstimate();
    } else if (mounted) {
      setState(() {
        _pickupLat = 13.7469;
        _pickupLng = 100.5392;
        _pickupController.text = 'Siam Paragon, Gate 1';
        _loadingLocation = false;
      });
      _animateMap();
      await _loadFareEstimate();
    }
  }

  void _animateMap() {
    final swLat = _pickupLat < _dropoffLat ? _pickupLat - 0.005 : _dropoffLat - 0.005;
    final swLng = _pickupLng < _dropoffLng ? _pickupLng - 0.005 : _dropoffLng - 0.005;
    final neLat = _pickupLat > _dropoffLat ? _pickupLat + 0.005 : _dropoffLat + 0.005;
    final neLng = _pickupLng > _dropoffLng ? _pickupLng + 0.005 : _dropoffLng + 0.005;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(swLat, swLng), northeast: LatLng(neLat, neLng)),
        60,
      ),
    );
  }

  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(_pickupLat, _pickupLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(title: 'Pickup'),
        ),
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(_dropoffLat, _dropoffLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Drop-off'),
        ),
      };

  Future<void> _loadFareEstimate() async {
    final ride = Provider.of<RideProvider>(context, listen: false);
    final success = await ride.getFareEstimate(
      vehicleType: _vehicleType,
      pickupLat: _pickupLat,
      pickupLng: _pickupLng,
      dropoffLat: _dropoffLat,
      dropoffLng: _dropoffLng,
    );
    if (success && ride.fareEstimate != null && mounted) {
      setState(() {
        _fareOffer = (ride.fareEstimate!['recommendedFare'] as num).toDouble();
        _fareOffer = _fareOffer.clamp(_minFare, _maxFare);
        _estimateLoaded = true;
      });
    } else if (mounted) {
      setState(() {
        _fareOffer = (_minFare + _maxFare) / 2;
        _estimateLoaded = true;
      });
    }
  }

  Future<void> _submitRequest() async {
    final ride = Provider.of<RideProvider>(context, listen: false);
    final estimate = ride.fareEstimate;
    final fareMin =
        estimate != null ? (estimate['fareMin'] as num).toDouble() : _minFare;
    final fareMax =
        estimate != null ? (estimate['fareMax'] as num).toDouble() : _maxFare;

    final success = await ride.createRideRequest(
      vehicleType: _vehicleType,
      pickupLat: _pickupLat,
      pickupLng: _pickupLng,
      pickupAddress: _pickupController.text,
      dropoffLat: _dropoffLat,
      dropoffLng: _dropoffLng,
      dropoffAddress: _dropoffController.text,
      fareMin: fareMin,
      fareMax: fareMax,
      fareOffer: _fareOffer,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/matching');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final localeProvider = context.watch<LocaleProvider>();
    return Scaffold(
      body: Consumer<RideProvider>(
        builder: (context, ride, _) {
          final estimate = ride.fareEstimate;
          final recommended =
              estimate != null ? (estimate['recommendedFare'] as num).toDouble() : _fareOffer;
          final fareMin = estimate != null
              ? (estimate['fareMin'] as num).toDouble()
              : _minFare;
          final fareMax = estimate != null
              ? (estimate['fareMax'] as num).toDouble()
              : _maxFare;
          final isFair = _fareOffer >= recommended - 10;

          return Stack(
            children: [
              // ── Full-screen GoogleMap ──
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_pickupLat, _pickupLng),
                    zoom: 13,
                  ),
                  markers: _markers,
                  onMapCreated: (c) {
                    _mapController = c;
                    if (!_loadingLocation) _animateMap();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onTap: (latLng) {
                    setState(() {
                      _dropoffLat = latLng.latitude;
                      _dropoffLng = latLng.longitude;
                      _dropoffController.text =
                          '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
                    });
                    _animateMap();
                    _loadFareEstimate();
                  },
                ),
              ),
              if (_loadingLocation)
                const Center(
                    child: CircularProgressIndicator(
                        color: FairGoTheme.primaryCyan)),

              // ── Top bar ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: FairGoTheme.textPrimary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              t.rideRequestTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: FairGoTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Map hint ──
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      localeProvider.isThai
                          ? 'แตะแผนที่เพื่อตั้งจุดหมาย'
                          : 'Tap map to set drop-off location',
                      style: const TextStyle(
                          fontSize: 11, color: FairGoTheme.textSecondary),
                    ),
                  ),
                ),
              ),

              // ── My Location button ──
              Positioned(
                right: 16,
                bottom: _estimateLoaded ? 420 : 300,
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
                        ),
                      ],
                    ),
                    child: const Icon(Icons.my_location_rounded,
                        color: FairGoTheme.primaryCyan, size: 22),
                  ),
                ),
              ),

              // ── Bottom Sheet ──
              DraggableScrollableSheet(
                initialChildSize: 0.52,
                minChildSize: 0.22,
                maxChildSize: 0.88,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(top: 10, bottom: 16),
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Route summary card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFF0F0F0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  child: Column(
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 10,
                                          color: FairGoTheme.primaryCyan),
                                      Container(
                                          width: 2,
                                          height: 20,
                                          color: const Color(0xFFE0E0E0)),
                                      const Icon(Icons.location_on_rounded,
                                          size: 14,
                                          color: FairGoTheme.danger),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _pickupController.text.isEmpty
                                            ? t.rideCurrentLocation
                                            : _pickupController.text,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _dropoffController.text,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: FairGoTheme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (estimate != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: FairGoTheme.primaryCyan
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(estimate['estimatedDistance'] as num?)?.toStringAsFixed(1) ?? '0'} km',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: FairGoTheme.primaryCyan,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Vehicle type selector
                          Row(
                            children: [
                              _VehicleOption(
                                icon: Icons.local_taxi_rounded,
                                label: t.vehicleTaxi,
                                isSelected: _vehicleType == 'TAXI',
                                onTap: () {
                                  setState(() => _vehicleType = 'TAXI');
                                  _loadFareEstimate();
                                },
                              ),
                              const SizedBox(width: 8),
                              _VehicleOption(
                                icon: Icons.two_wheeler_rounded,
                                label: t.vehicleMoto,
                                isSelected: _vehicleType == 'MOTORCYCLE',
                                onTap: () {
                                  setState(
                                      () => _vehicleType = 'MOTORCYCLE');
                                  _loadFareEstimate();
                                },
                              ),
                              const SizedBox(width: 8),
                              _VehicleOption(
                                icon: Icons.electric_rickshaw_rounded,
                                label: t.vehicleTuktuk,
                                isSelected: _vehicleType == 'TUKTUK',
                                onTap: () {
                                  setState(() => _vehicleType = 'TUKTUK');
                                  _loadFareEstimate();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          if (ride.isLoading && !_estimateLoaded)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: CircularProgressIndicator(
                                    color: FairGoTheme.primaryCyan),
                              ),
                            )
                          else ...[
                            // Big fare display
                            Center(
                              child: Text(
                                '฿${_fareOffer.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: FairGoTheme.primaryCyan,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Fairness badge
                            Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isFair
                                      ? FairGoTheme.success
                                          .withValues(alpha: 0.1)
                                      : FairGoTheme.warning
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isFair
                                          ? Icons.check_circle_rounded
                                          : Icons.info_rounded,
                                      size: 14,
                                      color: isFair
                                          ? FairGoTheme.success
                                          : FairGoTheme.warning,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isFair
                                          ? (localeProvider.isThai ? 'ราคานี้แฟร์สำหรับคุณและคนขับ' : 'Fair price for you and the driver')
                                          : (localeProvider.isThai ? 'ลองเพิ่มราคาเพื่อหาคนขับเร็วขึ้น' : 'Increase offer to find drivers faster'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isFair
                                            ? FairGoTheme.success
                                            : FairGoTheme.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Slider
                            Slider(
                              value: _fareOffer.clamp(fareMin, fareMax),
                              min: fareMin,
                              max: fareMax,
                              activeColor: FairGoTheme.primaryCyan,
                              inactiveColor: FairGoTheme.primaryCyan
                                  .withValues(alpha: 0.15),
                              onChanged: (v) =>
                                  setState(() => _fareOffer = v),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '฿${fareMin.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: FairGoTheme.textSecondary),
                                  ),
                                  Text(
                                    '${localeProvider.isThai ? 'แนะนำ' : 'Recommended'} ฿${recommended.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: FairGoTheme.primaryCyan,
                                    ),
                                  ),
                                  Text(
                                    '฿${fareMax.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: FairGoTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Quick adjust buttons
                            Row(
                              children: [
                                Text(
                                  localeProvider.isThai ? 'ปรับราคา: ' : 'Quick adjust: ',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: FairGoTheme.textSecondary),
                                ),
                                const SizedBox(width: 4),
                                ...[-10, 10, 20, 50].map((delta) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(right: 6),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _fareOffer =
                                              (_fareOffer + delta).clamp(
                                                  fareMin, fareMax);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: delta > 0
                                              ? FairGoTheme.primaryCyan
                                                  .withValues(alpha: 0.1)
                                              : FairGoTheme.danger
                                                  .withValues(alpha: 0.08),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${delta > 0 ? '+' : ''}$delta',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: delta > 0
                                                ? FairGoTheme.primaryCyan
                                                : FairGoTheme.danger,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Error
                            if (ride.error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  ride.error!,
                                  style: const TextStyle(
                                      color: FairGoTheme.danger,
                                      fontSize: 13),
                                ),
                              ),

                            // CTA
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: ride.isLoading
                                    ? null
                                    : _submitRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FairGoTheme.primaryCyan,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: ride.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : Text(
                                        localeProvider.isThai
                                            ? 'เรียกแฟร์โก · ฿${_fareOffer.toStringAsFixed(0)}'
                                            : 'Request FAIRGO · ฿${_fareOffer.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
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

class _VehicleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? FairGoTheme.primaryCyan : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? FairGoTheme.primaryCyan : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color:
                      isSelected ? Colors.white : FairGoTheme.textSecondary,
                  size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : FairGoTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
