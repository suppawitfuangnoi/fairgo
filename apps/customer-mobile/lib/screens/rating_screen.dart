import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/ride_provider.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 5;
  final Set<String> _selectedChips = {'Fair price'};
  final _commentController = TextEditingController();
  bool _addToFavorites = false;
  bool _submitting = false;

  final List<String> _chips = [
    'Fair price',
    'Friendly driver',
    'Clean car',
    'Safe driving',
    'Quick route',
    'Great music',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final trip =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (trip == null) return;
    setState(() => _submitting = true);

    try {
      final ride = Provider.of<RideProvider>(context, listen: false);
      await ride.submitRating(
        tripId: trip['id'],
        rating: _stars,
        comment: _commentController.text.isNotEmpty
            ? _commentController.text
            : _selectedChips.join(', '),
      );
    } catch (_) {}

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final driver = trip?['driverProfile'];
    final driverUser = driver?['user'];
    final driverName = driverUser?['name']?.toString() ?? 'Driver';
    final lockedFare = (trip?['lockedFare'] as num?)?.toDouble() ?? 0;
    final distance = trip?['estimatedDistance']?.toStringAsFixed(1) ?? '0';
    final duration = trip?['estimatedDuration']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: FairGoTheme.primaryCyan,
        elevation: 0,
        title: const Text(
          'RIDE COMPLETED',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Driver avatar with gradient border
            Container(
              width: 90,
              height: 90,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [FairGoTheme.primaryCyan, Color(0xFF0EA5C6)],
                ),
              ),
              child: CircleAvatar(
                backgroundColor:
                    FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                child: Text(
                  driverName.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: FairGoTheme.primaryCyan,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // "How was your ride?"
            const Text(
              'How was your ride?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: FairGoTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'with $driverName',
              style: const TextStyle(
                  fontSize: 14, color: FairGoTheme.textSecondary),
            ),
            const SizedBox(height: 16),

            // Trip stats pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: FairGoTheme.primaryCyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatPill(icon: Icons.route_rounded, value: '${distance}km'),
                  _StatDivider(),
                  _StatPill(
                      icon: Icons.attach_money_rounded,
                      value: '฿${lockedFare.toStringAsFixed(0)}'),
                  _StatDivider(),
                  _StatPill(
                      icon: Icons.access_time_rounded,
                      value: '${duration}min'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _stars = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 40,
                      color: i < _stars
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Feedback chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _chips.map((chip) {
                final selected = _selectedChips.contains(chip);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedChips.remove(chip);
                      } else {
                        _selectedChips.add(chip);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? FairGoTheme.primaryCyan
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? FairGoTheme.primaryCyan
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? Colors.white : FairGoTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Comment box
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us more about your ride...',
                hintStyle: const TextStyle(
                    fontSize: 13, color: Color(0xFFBDBDBD)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: FairGoTheme.primaryCyan),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add to favorites toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite_border_rounded,
                      color: FairGoTheme.danger, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Add driver to favorites',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Switch(
                    value: _addToFavorites,
                    onChanged: (v) => setState(() => _addToFavorites = v),
                    activeColor: FairGoTheme.primaryCyan,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FairGoTheme.primaryCyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false),
              child: const Text(
                'Skip for now',
                style: TextStyle(color: FairGoTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatPill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: FairGoTheme.primaryCyan),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FairGoTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 1,
      height: 14,
      color: FairGoTheme.primaryCyan.withValues(alpha: 0.3),
    );
  }
}
