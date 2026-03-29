import 'package:flutter/material.dart';
import '../config/theme.dart';

class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final lockedFare = (trip?['lockedFare'] as num?)?.toDouble() ?? 0;
    final pickupAddress = trip?['pickupAddress'] ?? 'Pickup location';
    final dropoffAddress = trip?['dropoffAddress'] ?? 'Dropoff location';
    final driver = trip?['driverProfile'];
    final driverUser = driver?['user'];
    final driverName = driverUser?['name']?.toString() ?? 'Driver';
    final rating = driver?['averageRating']?.toStringAsFixed(1) ?? '0.0';
    final createdAt = trip?['createdAt']?.toString() ?? '';
    final updatedAt = trip?['updatedAt']?.toString() ?? '';

    // Payment breakdown — lockedFare is the agreed fare (100%)
    final platformFee = (lockedFare * 0.10).roundToDouble();
    final driverPayout = (lockedFare - platformFee).roundToDouble();
    final promo = 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: Column(
        children: [
          // ── Gradient header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [FairGoTheme.primaryCyan, Color(0xFF0EA5C6)],
              ),
            ),
            child: Column(
              children: [
                // Check circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ถึงจุดหมายแล้ว!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ขอบคุณที่ใช้บริการ FAIRGO',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 20),
                // Total paid badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ชำระแล้ว',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '฿${lockedFare.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Receipt card ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Route card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Column(
                      children: [
                        _RouteRow(
                          icon: Icons.circle,
                          iconColor: FairGoTheme.primaryCyan,
                          address: pickupAddress,
                          time: createdAt.length >= 16
                              ? createdAt.substring(11, 16)
                              : '',
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 18,
                                child: VerticalDivider(
                                    color: Color(0xFFE0E0E0), width: 1),
                              ),
                            ],
                          ),
                        ),
                        _RouteRow(
                          icon: Icons.location_on_rounded,
                          iconColor: FairGoTheme.danger,
                          address: dropoffAddress,
                          time: updatedAt.length >= 16
                              ? updatedAt.substring(11, 16)
                              : '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Driver + quick rating
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                          child: Text(
                            driverName.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 18,
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
                                driverName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 13,
                                      color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: FairGoTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Quick stars
                        Row(
                          children: List.generate(
                            5,
                            (i) => const Icon(Icons.star_rounded,
                                size: 20, color: Color(0xFFF59E0B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment breakdown
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
                        const Text(
                          'รายละเอียดการชำระ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: FairGoTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _PaymentRow(label: 'ค่าโดยสารตกลง', amount: lockedFare),
                        _PaymentRow(label: 'ส่วนแบ่งแพลตฟอร์ม (10%)', amount: platformFee, isDiscount: false, isSubInfo: true),
                        _PaymentRow(label: 'คนขับได้รับ (90%)', amount: driverPayout, isDiscount: false, isSubInfo: true),
                        if (promo < 0)
                          _PaymentRow(
                            label: 'ส่วนลดโปรโมชัน',
                            amount: promo,
                            isDiscount: true,
                          ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'รวมทั้งหมด',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '฿${lockedFare.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: FairGoTheme.primaryCyan,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Go Home button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/home', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FairGoTheme.primaryCyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'กลับหน้าหลัก',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Rate driver button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/rate-driver',
                            arguments: trip);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FairGoTheme.primaryCyan,
                        side: const BorderSide(color: FairGoTheme.primaryCyan),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'ให้คะแนนคนขับ',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String address;
  final String time;

  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.address,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (time.isNotEmpty)
          Text(
            time,
            style: const TextStyle(
                fontSize: 11, color: FairGoTheme.textSecondary),
          ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDiscount;
  final bool isSubInfo;

  const _PaymentRow({
    required this.label,
    required this.amount,
    this.isDiscount = false,
    this.isSubInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSubInfo ? 11 : 13,
              color: isSubInfo ? const Color(0xFFBDBDBD) : FairGoTheme.textSecondary,
            ),
          ),
          Text(
            isDiscount
                ? '-฿${amount.abs().toStringAsFixed(0)}'
                : '฿${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isSubInfo ? 11 : 13,
              fontWeight: FontWeight.w600,
              color: isDiscount
                  ? FairGoTheme.success
                  : isSubInfo
                      ? const Color(0xFFBDBDBD)
                      : FairGoTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
