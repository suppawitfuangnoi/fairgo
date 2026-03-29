import 'package:flutter/material.dart';
import '../config/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'ตั้งราคาที่คุณ',
      titleHighlight: 'แฟร์',
      description:
          'เลือกราคาที่คุณพอใจ เสนอราคาได้เอง คนขับพร้อมรับข้อเสนอของคุณ เดินทางสบายใจในราคาที่คุณกำหนด',
      badgeLabel: 'ราคาที่ตกลงกัน',
      badgeValue: '฿120.00',
      badgeIcon: Icons.thumb_up_rounded,
      iconMain: Icons.handshake_rounded,
    ),
    _OnboardingData(
      title: 'คนขับ',
      titleHighlight: 'ที่ไว้ใจได้',
      description:
          'คนขับที่ผ่านการตรวจสอบ มีคะแนนรีวิวจริง ติดตามการเดินทางแบบ real-time ปลอดภัยทุกเส้นทาง',
      badgeLabel: 'คะแนนเฉลี่ย',
      badgeValue: '4.9 ★',
      badgeIcon: Icons.verified_rounded,
      iconMain: Icons.shield_rounded,
    ),
    _OnboardingData(
      title: 'เดินทางได้ทุก',
      titleHighlight: 'ที่ทุกเวลา',
      description:
          'เรียกรถได้ทันที ไม่ว่าจะเป็นแท็กซี่ มอเตอร์ไซค์ หรือตุ๊กตุ๊ก มีให้เลือกครบทุกประเภท',
      badgeLabel: 'พร้อมให้บริการ',
      badgeValue: '24/7',
      badgeIcon: Icons.access_time_rounded,
      iconMain: Icons.directions_car_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 12,
              right: 20,
              child: TextButton(
                onPressed: _skip,
                style: TextButton.styleFrom(
                  foregroundColor: FairGoTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'ข้าม (Skip)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 50),
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: _pages[index],
                        floatAnimation: _floatAnimation,
                      );
                    },
                  ),
                ),

                // Bottom controls
                Container(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 36),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF6F8F8).withValues(alpha: 0),
                        const Color(0xFFF6F8F8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Pagination dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _currentPage ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _currentPage
                                  ? FairGoTheme.primaryCyan
                                  : const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      // CTA button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _nextPage,
                          icon: const SizedBox.shrink(),
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage < _pages.length - 1
                                    ? 'ต่อไป'
                                    : 'เริ่มต้นใช้งาน',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FairGoTheme.primaryCyan,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: FairGoTheme.primaryCyan.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String titleHighlight;
  final String description;
  final String badgeLabel;
  final String badgeValue;
  final IconData badgeIcon;
  final IconData iconMain;

  const _OnboardingData({
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.badgeLabel,
    required this.badgeValue,
    required this.badgeIcon,
    required this.iconMain,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> floatAnimation;

  const _OnboardingPage({
    required this.data,
    required this.floatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Illustration area
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background blob
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        FairGoTheme.primaryCyan.withValues(alpha: 0.12),
                        FairGoTheme.primaryCyan.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
                // Floating main icon
                AnimatedBuilder(
                  animation: floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, floatAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: FairGoTheme.primaryCyan.withValues(alpha: 0.25),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Icon(
                      data.iconMain,
                      size: 70,
                      color: FairGoTheme.primaryCyan,
                    ),
                  ),
                ),
                // Floating badge
                Positioned(
                  bottom: 30,
                  right: 20,
                  child: AnimatedBuilder(
                    animation: floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -floatAnimation.value * 0.5),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: FairGoTheme.primaryCyan.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              data.badgeIcon,
                              size: 16,
                              color: FairGoTheme.primaryCyan,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                data.badgeLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: FairGoTheme.textSecondary,
                                ),
                              ),
                              Text(
                                data.badgeValue,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: FairGoTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text content
          Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: FairGoTheme.textPrimary,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(text: data.title),
                    TextSpan(
                      text: data.titleHighlight,
                      style: const TextStyle(color: FairGoTheme.primaryCyan),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: FairGoTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
