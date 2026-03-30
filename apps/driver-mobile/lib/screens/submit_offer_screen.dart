import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/job_provider.dart';
import '../providers/locale_provider.dart';

class SubmitOfferScreen extends StatefulWidget {
  const SubmitOfferScreen({super.key});

  @override
  State<SubmitOfferScreen> createState() => _SubmitOfferScreenState();
}

class _SubmitOfferScreenState extends State<SubmitOfferScreen> {
  double _offerAmount = 0;
  int _etaMinutes = 5;
  final _messageController = TextEditingController();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ride = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (ride != null) {
        setState(() {
          _offerAmount = (ride['fareOffer'] as num?)?.toDouble() ?? 100;
        });
        _fitMapBounds(ride);
      }
    });
  }

  void _fitMapBounds(Map<String, dynamic> ride) {
    final pickupLat = (ride['pickupLatitude'] as num?)?.toDouble();
    final pickupLng = (ride['pickupLongitude'] as num?)?.toDouble();
    final dropoffLat = (ride['dropoffLatitude'] as num?)?.toDouble();
    final dropoffLng = (ride['dropoffLongitude'] as num?)?.toDouble();
    if (pickupLat == null || pickupLng == null || dropoffLat == null || dropoffLng == null) return;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            pickupLat < dropoffLat ? pickupLat - 0.005 : dropoffLat - 0.005,
            pickupLng < dropoffLng ? pickupLng - 0.005 : dropoffLng - 0.005,
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

  Set<Marker> _buildMarkers(Map<String, dynamic> ride) {
    final markers = <Marker>{};
    final pickupLat = (ride['pickupLatitude'] as num?)?.toDouble();
    final pickupLng = (ride['pickupLongitude'] as num?)?.toDouble();
    final dropoffLat = (ride['dropoffLatitude'] as num?)?.toDouble();
    final dropoffLng = (ride['dropoffLongitude'] as num?)?.toDouble();
    if (pickupLat != null && pickupLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickupLat, pickupLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(title: 'Pickup', snippet: ride['pickupAddress'] ?? ''),
      ));
    }
    if (dropoffLat != null && dropoffLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(dropoffLat, dropoffLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Drop-off', snippet: ride['dropoffAddress'] ?? ''),
      ));
    }
    return markers;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ride = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (ride == null) return;

    final jobs = Provider.of<JobProvider>(context, listen: false);
    final success = await jobs.submitOffer(
      rideRequestId: ride['id'],
      fareAmount: _offerAmount,
      estimatedPickupMinutes: _etaMinutes,
      message: _messageController.text.isNotEmpty ? _messageController.text : null,
    );

    if (success && mounted) {
      final t = Provider.of<LocaleProvider>(context, listen: false).t;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.submitOfferSuccess),
          backgroundColor: FairGoTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().t;
    final ride = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (ride == null) {
      return const Scaffold(body: Center(child: Text('No ride data')));
    }

    final fareMin = (ride['fareMin'] as num?)?.toDouble() ?? 0;
    final fareMax = (ride['fareMax'] as num?)?.toDouble() ?? 500;
    final fareOffer = (ride['fareOffer'] as num?)?.toDouble() ?? 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: Stack(
        children: [
          // ── Full map at top ──
          SizedBox(
            height: 260,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  (ride['pickupLatitude'] as num?)?.toDouble() ?? 13.7563,
                  (ride['pickupLongitude'] as num?)?.toDouble() ?? 100.5018,
                ),
                zoom: 13,
              ),
              markers: _buildMarkers(ride),
              onMapCreated: (c) {
                _mapController = c;
                _fitMapBounds(ride);
              },
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),

          // ── Back button overlay on map ──
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: FairGoTheme.textPrimary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        t.submitOfferTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: FairGoTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable content card (overlaps map) ──
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF6F8F8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // Ride route summary
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
                      Expanded(child: Text(ride['pickupAddress'] ?? '', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                      Expanded(child: Text(ride['dropoffAddress'] ?? '', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${t.submitPassengerOffer}: ฿${fareOffer.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FairGoTheme.primaryCyan)),
                      Text('${t.submitFareRange}: ฿${fareMin.toStringAsFixed(0)} - ฿${fareMax.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('${ride['estimatedDistance']?.toStringAsFixed(1) ?? '0'} km', style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary)),
                      const SizedBox(width: 12),
                      Text('~${ride['estimatedDuration'] ?? 0} min', style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Your offer amount
            Text(t.submitYourFareOffer, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
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
                    '฿${_offerAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: FairGoTheme.primaryCyan),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _offerAmount.clamp(fareMin, fareMax),
                    min: fareMin,
                    max: fareMax,
                    activeColor: FairGoTheme.primaryCyan,
                    inactiveColor: FairGoTheme.primaryCyan.withValues(alpha: 0.2),
                    onChanged: (v) => setState(() => _offerAmount = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('฿${fareMin.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary)),
                      Text('฿${fareMax.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ETA
            Text(t.submitEtaTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [3, 5, 8, 10, 15].map((min) {
                final isSelected = _etaMinutes == min;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _etaMinutes = min),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? FairGoTheme.primaryCyan : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? FairGoTheme.primaryCyan : const Color(0xFFE5E7EB)),
                      ),
                      child: Center(
                        child: Text(
                          '$min min',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : FairGoTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Message
            Text(t.submitMessageTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8ECEE)),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: t.submitMessageHint,
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            Consumer<JobProvider>(
              builder: (context, jobs, _) {
                return Column(
                  children: [
                    if (jobs.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(jobs.error!, style: const TextStyle(color: FairGoTheme.danger, fontSize: 13)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: jobs.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FairGoTheme.primaryCyan,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: jobs.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(
                                t.submitOfferButton(_offerAmount.toStringAsFixed(0)),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
                  ], // Column.children list
                ), // Column widget
              ), // SingleChildScrollView
            ), // Container card
          ), // Positioned content
          ], // Stack children
        ), // Stack body
    ); // Scaffold
  }
}
