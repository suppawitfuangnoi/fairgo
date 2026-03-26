import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/ride_provider.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final _pickupController = TextEditingController(text: 'Siam Paragon, Gate 1');
  final _dropoffController = TextEditingController(text: 'ICONSIAM, Charoen Nakhon Rd');
  String _vehicleType = 'TAXI';
  double _fareOffer = 165; // Default to middle of range
  bool _estimateLoaded = false;
  static const double _minFare = 80;
  static const double _maxFare = 250;

  // Mock coordinates
  final double _pickupLat = 13.7469;
  final double _pickupLng = 100.5392;
  final double _dropoffLat = 13.7262;
  final double _dropoffLng = 100.5098;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() => _vehicleType = args);
      }
      _loadFareEstimate();
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<void> _loadFareEstimate() async {
    final ride = Provider.of<RideProvider>(context, listen: false);
    final success = await ride.getFareEstimate(
      vehicleType: _vehicleType,
      pickupLat: _pickupLat,
      pickupLng: _pickupLng,
      dropoffLat: _dropoffLat,
      dropoffLng: _dropoffLng,
    );
    if (success && ride.fareEstimate != null) {
      setState(() {
        _fareOffer = (ride.fareEstimate!['recommendedFare'] as num).toDouble();
        // Clamp to 80-250 range
        _fareOffer = _fareOffer.clamp(_minFare, _maxFare);
        _estimateLoaded = true;
      });
    } else {
      // Use default range if estimate fails
      setState(() {
        _fareOffer = (_minFare + _maxFare) / 2;
        _estimateLoaded = true;
      });
    }
  }

  Future<void> _submitRequest() async {
    final ride = Provider.of<RideProvider>(context, listen: false);
    final estimate = ride.fareEstimate;

    // Use provided estimate or default range
    final fareMin = estimate != null ? (estimate['fareMin'] as num).toDouble() : _minFare;
    final fareMax = estimate != null ? (estimate['fareMax'] as num).toDouble() : _maxFare;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Ride'),
        backgroundColor: FairGoTheme.primaryCyan,
      ),
      body: Consumer<RideProvider>(
        builder: (context, ride, _) {
          final estimate = ride.fareEstimate;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route inputs
                Container(
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
                          Column(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: FairGoTheme.primaryCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 30,
                                color: const Color(0xFFE0E0E0),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: FairGoTheme.danger,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _pickupController,
                                  decoration: const InputDecoration(
                                    labelText: 'PICKUP',
                                    labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: FairGoTheme.primaryCyan),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const Divider(height: 16),
                                TextField(
                                  controller: _dropoffController,
                                  decoration: const InputDecoration(
                                    labelText: 'DROP-OFF',
                                    labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: FairGoTheme.danger),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Vehicle type selector
                const Text(
                  'Vehicle Type',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: FairGoTheme.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _VehicleOption(
                      icon: Icons.local_taxi_rounded,
                      label: 'Taxi',
                      isSelected: _vehicleType == 'TAXI',
                      onTap: () {
                        setState(() => _vehicleType = 'TAXI');
                        _loadFareEstimate();
                      },
                    ),
                    const SizedBox(width: 10),
                    _VehicleOption(
                      icon: Icons.two_wheeler_rounded,
                      label: 'Motorcycle',
                      isSelected: _vehicleType == 'MOTORCYCLE',
                      onTap: () {
                        setState(() => _vehicleType = 'MOTORCYCLE');
                        _loadFareEstimate();
                      },
                    ),
                    const SizedBox(width: 10),
                    _VehicleOption(
                      icon: Icons.electric_rickshaw_rounded,
                      label: 'Tuk-Tuk',
                      isSelected: _vehicleType == 'TUKTUK',
                      onTap: () {
                        setState(() => _vehicleType = 'TUKTUK');
                        _loadFareEstimate();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Fare estimate card
                if (ride.isLoading && !_estimateLoaded)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: FairGoTheme.primaryCyan),
                    ),
                  )
                else if (estimate != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: FairGoTheme.primaryCyan.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Fare Estimate',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: FairGoTheme.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: FairGoTheme.primaryCyan.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(estimate['estimatedDistance'] as num?)?.toStringAsFixed(1) ?? '0'} km · ${estimate['estimatedDuration'] ?? 0} min',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: FairGoTheme.primaryCyan,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FareItem(label: 'Min', value: '฿${estimate['fareMin']}'),
                            _FareItem(
                              label: 'Recommended',
                              value: '฿${estimate['recommendedFare']}',
                              isHighlighted: true,
                            ),
                            _FareItem(label: 'Max', value: '฿${estimate['fareMax']}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Your offer
                  const Text(
                    'Your Fare Offer',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: FairGoTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '฿${_fareOffer.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: FairGoTheme.primaryCyan,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: _fareOffer,
                          min: _minFare,
                          max: _maxFare,
                          activeColor: FairGoTheme.primaryCyan,
                          inactiveColor: FairGoTheme.primaryCyan.withValues(alpha: 0.2),
                          onChanged: (value) {
                            setState(() => _fareOffer = value);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '฿${_minFare.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary),
                            ),
                            Text(
                              '฿${_maxFare.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: ride.isLoading ? null : _submitRequest,
                    child: ride.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Request Ride · ฿${_fareOffer.toStringAsFixed(0)}'),
                  ),
                ],

                if (ride.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      ride.error!,
                      style: const TextStyle(color: FairGoTheme.danger, fontSize: 13),
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
              color: isSelected ? FairGoTheme.primaryCyan : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : FairGoTheme.textSecondary, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
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

class _FareItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _FareItem({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isHighlighted ? FairGoTheme.primaryCyan : FairGoTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? FairGoTheme.primaryCyan : FairGoTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
