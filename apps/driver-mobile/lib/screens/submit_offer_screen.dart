import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/job_provider.dart';

class SubmitOfferScreen extends StatefulWidget {
  const SubmitOfferScreen({super.key});

  @override
  State<SubmitOfferScreen> createState() => _SubmitOfferScreenState();
}

class _SubmitOfferScreenState extends State<SubmitOfferScreen> {
  double _offerAmount = 0;
  int _etaMinutes = 5;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ride = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (ride != null) {
        setState(() {
          _offerAmount = (ride['fareOffer'] as num?)?.toDouble() ?? 100;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer submitted! Waiting for passenger response.'),
          backgroundColor: FairGoTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (ride == null) {
      return const Scaffold(body: Center(child: Text('No ride data')));
    }

    final fareMin = (ride['fareMin'] as num?)?.toDouble() ?? 0;
    final fareMax = (ride['fareMax'] as num?)?.toDouble() ?? 500;
    final fareOffer = (ride['fareOffer'] as num?)?.toDouble() ?? 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Offer'),
        backgroundColor: FairGoTheme.primaryCyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ride details
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
                      Text('Passenger offer: ฿${fareOffer.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FairGoTheme.primaryCyan)),
                      Text('Range: ฿${fareMin.toStringAsFixed(0)} - ฿${fareMax.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: FairGoTheme.textSecondary)),
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
            const Text('Your Fare Offer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
            const Text('Estimated Pickup Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
            const Text('Message (Optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g., "I\'m nearby, can pick you up quickly!"',
                hintStyle: TextStyle(fontSize: 13),
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
                    ElevatedButton(
                      onPressed: jobs.isLoading ? null : _submit,
                      child: jobs.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Submit Offer · ฿${_offerAmount.toStringAsFixed(0)}'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
