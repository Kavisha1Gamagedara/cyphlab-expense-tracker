import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../state/auth_provider.dart';

/// Available themes for the onboarding pool
enum OnboardingType {
  walletPeace,
  visualBreakdown,
  levelUp,
  brainClarity,
  budgetWinning,
}

/// Data model for an onboarding slide
class OnboardingItem {
  final OnboardingType type;
  final String title;
  final String subtitle;
  final Color pastelColor;
  final Color doodleAccent;

  const OnboardingItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.pastelColor,
    required this.doodleAccent,
  });
}

/// Pool of creative, playful financial onboarding slides
const List<OnboardingItem> kOnboardingPool = [
  OnboardingItem(
    type: OnboardingType.walletPeace,
    title: 'Your Wallet Called.\nIt Wants Peace. 🕊️',
    subtitle: '😌 Small tracks. Big savings. Zero stress.',
    pastelColor: Color(0xFFE9D5FF), // Soft lilac (exact match to screenshot)
    doodleAccent: Color(0xFFA855F7),
  ),
  OnboardingItem(
    type: OnboardingType.visualBreakdown,
    title: 'Where Did It Go?\nSolved Forever. 🔍',
    subtitle: '⚡ Instant category breakdowns & live monthly targets.',
    pastelColor: Color(0xFFBAF7D0), // Soft mint / sage
    doodleAccent: Color(0xFF22C55E),
  ),
  OnboardingItem(
    type: OnboardingType.levelUp,
    title: 'Level Up Your Money.\nOne Day At A Time. 🚀',
    subtitle: '🎯 Set limits, track daily, and celebrate every win.',
    pastelColor: Color(0xFFFED7AA), // Soft warm peach / apricot
    doodleAccent: Color(0xFFF97316),
  ),
  OnboardingItem(
    type: OnboardingType.brainClarity,
    title: 'Your Brain Called.\nIt Wants Clarity. 🧠',
    subtitle: '💡 No spreadsheets. No headaches. Just smart insights.',
    pastelColor: Color(0xFFBAE6FD), // Soft sky blue
    doodleAccent: Color(0xFF0284C7),
  ),
  OnboardingItem(
    type: OnboardingType.budgetWinning,
    title: 'Budgeting That Feels\nLike Winning. 🏆',
    subtitle: '✨ Stay on track, hit your goals, and unlock peace of mind.',
    pastelColor: Color(0xFFFCE7F3), // Soft rose
    doodleAccent: Color(0xFFEC4899),
  ),
];

/// Creative Onboarding experience shown strictly for newly registered users.
/// Directly inspired by the playful, high-contrast Dribbble concept art.
class OnboardingScreen extends StatefulWidget {
  final bool isPreview;

  const OnboardingScreen({
    super.key,
    this.isPreview = false,
  });

  /// Allows opening onboarding as a preview (e.g., from settings)
  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const OnboardingScreen(isPreview: true),
      ),
    );
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  late final List<OnboardingItem> _pages;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Select 3 random onboarding slides from the pool for new users
    final pool = List<OnboardingItem>.from(kOnboardingPool)..shuffle();
    _pages = pool.take(3).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding(BuildContext context) {
    if (widget.isPreview) {
      Navigator.of(context).pop();
    } else {
      context.read<AuthProvider>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Navigation & Branding Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Branding Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : const Color(0xFF18181B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: isDark ? Colors.white : Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Page Step Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentPage + 1} of ${_pages.length}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white70 : const Color(0xFF18181B),
                      ),
                    ),
                  ),

                  // Skip Button
                  TextButton(
                    onPressed: () => _finishOnboarding(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Skip',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF71717A),
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: isDark ? Colors.white70 : const Color(0xFF71717A),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // PageView of 3 Random Screens
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];

                  return Column(
                    children: [
                      // Top Half: Vector/Doodle Illustration
                      Expanded(
                        flex: 11,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: CustomPaint(
                              size: const Size(300, 260),
                              painter: OnboardingIllustrationPainter(
                                type: item.type,
                                isDark: isDark,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Half: Pastel Card with Headline, Subtitle, & Progress Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: item.pastelColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(38),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, -6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Doodle Decor 1: 4-pointed Sparkle Star (Bottom Left)
                            Positioned(
                              left: 28,
                              bottom: 38,
                              child: _buildSparkleStar(size: 22, color: const Color(0xFFFDE047)),
                            ),
                            // Doodle Decor 2: 4-pointed Sparkle Star (Top Right)
                            Positioned(
                              right: 28,
                              top: 24,
                              child: _buildSparkleStar(size: 20, color: const Color(0xFFFDE047)),
                            ),
                            // Doodle Decor 3: Hollow Circle (Middle Right)
                            Positioned(
                              right: 32,
                              bottom: 44,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF18181B), width: 2),
                                ),
                              ),
                            ),
                            // Doodle Decor 4: Small Sparkle Dot (Top Left)
                            Positioned(
                              left: 36,
                              top: 28,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF18181B),
                                ),
                              ),
                            ),

                            // Main Content Column
                            Padding(
                              padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Punchy Headline
                                  Text(
                                    item.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF18181B),
                                      height: 1.22,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Subtitle with Emoji
                                  Text(
                                    item.subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF18181B).withValues(alpha: 0.82),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 34),

                                  // Dribbble-style Circular Action Button with Progress Arc
                                  _buildProgressButton(context, index),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4-pointed sparkle star doodle
  Widget _buildSparkleStar({required double size, required Color color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: StarDoodlePainter(color: color),
      ),
    );
  }

  /// Circular Action Button with outer animated progress ring (matching reference image)
  Widget _buildProgressButton(BuildContext context, int index) {
    final progress = (index + 1) / _pages.length;
    final isLast = index == _pages.length - 1;

    return GestureDetector(
      onTap: () {
        if (isLast) {
          _finishOnboarding(context);
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeInOutCubic,
          );
        }
      },
      child: SizedBox(
        width: 86,
        height: 86,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer background subtle ring
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 3.5,
                ),
              ),
            ),

            // Animated Black Progress Arc
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return CustomPaint(
                  size: const Size(80, 80),
                  painter: CircularProgressArcPainter(
                    progress: val,
                    strokeWidth: 3.5,
                    color: const Color(0xFF18181B),
                  ),
                );
              },
            ),

            // Inner Solid Black Circular Button
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the outer circular progress arc around the button
class CircularProgressArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  CircularProgressArcPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Arc starts at top (-pi / 2) and sweeps around clockwise
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}

/// Paints a small 4-point doodle star
class StarDoodlePainter extends CustomPainter {
  final Color color;

  StarDoodlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF18181B)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final inR = r * 0.32;

    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * (math.pi / 2) - math.pi / 2;
      final nextAngle = angle + (math.pi / 4);

      if (i == 0) {
        path.moveTo(cx + r * math.cos(angle), cy + r * math.sin(angle));
      } else {
        path.lineTo(cx + r * math.cos(angle), cy + r * math.sin(angle));
      }
      path.lineTo(cx + inR * math.cos(nextAngle), cy + inR * math.sin(nextAngle));
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant StarDoodlePainter oldDelegate) => oldDelegate.color != color;
}

/// Hand-drawn line art and pastel vector illustration painter
class OnboardingIllustrationPainter extends CustomPainter {
  final OnboardingType type;
  final bool isDark;

  OnboardingIllustrationPainter({
    required this.type,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw universal background doodles (puzzle piece, stars, bubbles)
    _drawBackgroundDoodles(canvas, cx, cy);

    // Draw specific scene subject
    switch (type) {
      case OnboardingType.walletPeace:
        _drawWalletPeaceScene(canvas, cx, cy);
        break;
      case OnboardingType.visualBreakdown:
        _drawVisualBreakdownScene(canvas, cx, cy);
        break;
      case OnboardingType.levelUp:
        _drawLevelUpScene(canvas, cx, cy);
        break;
      case OnboardingType.brainClarity:
        _drawBrainClarityScene(canvas, cx, cy);
        break;
      case OnboardingType.budgetWinning:
        _drawBudgetWinningScene(canvas, cx, cy);
        break;
    }
  }

  /// Universal Dribbble background doodles
  void _drawBackgroundDoodles(Canvas canvas, double cx, double cy) {
    // 1. Diagonal-hatched Puzzle Piece on the left (direct match to image)
    _drawPuzzlePiece(canvas, Offset(cx - 105, cy + 30), 44, const Color(0xFFF472B6));

    // 2. Yellow 4-point Sparkle Stars
    _drawSparkleStar(canvas, Offset(cx + 95, cy - 75), 20, const Color(0xFFFDE047));
    _drawSparkleStar(canvas, Offset(cx - 100, cy - 80), 16, const Color(0xFFFACC15));

    // 3. Hollow Circles
    _drawHollowCircle(canvas, Offset(cx + 105, cy - 25), 8);
    _drawHollowCircle(canvas, Offset(cx - 110, cy - 35), 6);
    _drawHollowCircle(canvas, Offset(cx + 85, cy + 85), 5);
  }

  /// Scene 1: Character sitting on stacked books/wallets with laptop (exact Dribbble theme)
  void _drawWalletPeaceScene(Canvas canvas, double cx, double cy) {
    final stroke = Paint()
      ..color = const Color(0xFF18181B)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillWhite = Paint()..color = Colors.white;

    // Stack of 3 Books / Platforms
    // Bottom Book
    final book3 = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 72), width: 175, height: 26),
      const Radius.circular(5),
    );
    canvas.drawRRect(book3, fillWhite);
    canvas.drawRRect(book3, stroke);

    // Middle Book with dangling yellow bookmark
    final book2 = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 5, cy + 46), width: 165, height: 26),
      const Radius.circular(5),
    );
    canvas.drawRRect(book2, fillWhite);
    canvas.drawRRect(book2, stroke);

    // Yellow Bookmark dangling
    final bookmarkPath = Path()
      ..moveTo(cx + 25, cy + 33)
      ..lineTo(cx + 42, cy + 33)
      ..lineTo(cx + 42, cy + 62)
      ..lineTo(cx + 33.5, cy + 54)
      ..lineTo(cx + 25, cy + 62)
      ..close();
    canvas.drawPath(bookmarkPath, Paint()..color = const Color(0xFFFACC15));
    canvas.drawPath(bookmarkPath, stroke);

    // Top Book
    final book1 = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 2, cy + 20), width: 155, height: 26),
      const Radius.circular(5),
    );
    canvas.drawRRect(book1, fillWhite);
    canvas.drawRRect(book1, stroke);

    // Horizontal spine lines on books
    canvas.drawLine(Offset(cx - 70, cy + 20), Offset(cx + 60, cy + 20), stroke..strokeWidth = 1.6);
    canvas.drawLine(Offset(cx - 75, cy + 72), Offset(cx + 70, cy + 72), stroke..strokeWidth = 1.6);
    stroke.strokeWidth = 2.4;

    // Character sitting on top:
    // Dangling Legs (Teal pants)
    final legPaint = Paint()..color = const Color(0xFF2DD4BF);
    final leg1 = Path()
      ..moveTo(cx - 22, cy + 10)
      ..lineTo(cx - 52, cy + 52)
      ..lineTo(cx - 40, cy + 56)
      ..lineTo(cx - 12, cy + 16)
      ..close();
    canvas.drawPath(leg1, legPaint);
    canvas.drawPath(leg1, stroke);

    final leg2 = Path()
      ..moveTo(cx - 5, cy + 10)
      ..lineTo(cx - 26, cy + 62)
      ..lineTo(cx - 15, cy + 64)
      ..lineTo(cx + 6, cy + 16)
      ..close();
    canvas.drawPath(leg2, legPaint);
    canvas.drawPath(leg2, stroke);

    // Sneakers
    final shoe1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 68, cy + 48, 22, 11),
      const Radius.circular(6),
    );
    canvas.drawRRect(shoe1, fillWhite);
    canvas.drawRRect(shoe1, stroke);

    final shoe2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 36, cy + 58, 22, 11),
      const Radius.circular(6),
    );
    canvas.drawRRect(shoe2, fillWhite);
    canvas.drawRRect(shoe2, stroke);

    // Torso (Purple sweater)
    final torso = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 6, cy - 25), width: 34, height: 42),
      const Radius.circular(10),
    );
    canvas.drawRRect(torso, Paint()..color = const Color(0xFFC084FC));
    canvas.drawRRect(torso, stroke);

    // Laptop open on lap
    final laptopScreen = Path()
      ..moveTo(cx - 36, cy - 35)
      ..lineTo(cx - 18, cy - 5)
      ..lineTo(cx - 15, cy - 5)
      ..lineTo(cx - 30, cy - 36)
      ..close();
    canvas.drawPath(laptopScreen, fillWhite);
    canvas.drawPath(laptopScreen, stroke);

    final laptopBase = Path()
      ..moveTo(cx - 22, cy - 5)
      ..lineTo(cx + 14, cy - 5)
      ..lineTo(cx + 12, cy - 1)
      ..lineTo(cx - 24, cy - 1)
      ..close();
    canvas.drawPath(laptopBase, fillWhite);
    canvas.drawPath(laptopBase, stroke);

    // Arms
    final arm = Path()
      ..moveTo(cx + 12, cy - 32)
      ..lineTo(cx - 6, cy - 10)
      ..lineTo(cx - 2, cy - 6)
      ..lineTo(cx + 18, cy - 26)
      ..close();
    canvas.drawPath(arm, Paint()..color = const Color(0xFFC084FC));
    canvas.drawPath(arm, stroke);

    // Head
    canvas.drawCircle(Offset(cx + 10, cy - 56), 14, Paint()..color = const Color(0xFFFED7AA));
    canvas.drawCircle(Offset(cx + 10, cy - 56), 14, stroke);

    // Hair / Cap
    final cap = Path()
      ..moveTo(cx - 6, cy - 64)
      ..lineTo(cx + 26, cy - 64)
      ..lineTo(cx + 20, cy - 72)
      ..lineTo(cx, cy - 72)
      ..close();
    canvas.drawPath(cap, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawPath(cap, stroke);

    // Facial features: happy eye curve
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx + 4, cy - 56), radius: 3),
      0,
      math.pi,
      false,
      stroke..strokeWidth = 1.8,
    );
  }

  /// Scene 2: Magnifying glass inspecting smart category bar charts & coins
  void _drawVisualBreakdownScene(Canvas canvas, double cx, double cy) {
    final stroke = Paint()
      ..color = const Color(0xFF18181B)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillWhite = Paint()..color = Colors.white;

    // Analytics Card in background
    final card = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 10, cy + 10), width: 140, height: 110),
      const Radius.circular(16),
    );
    canvas.drawRRect(card, fillWhite);
    canvas.drawRRect(card, stroke);

    // Category Bars inside Card
    final barColors = [
      const Color(0xFF34D399), // Mint
      const Color(0xFFA78BFA), // Violet
      const Color(0xFFFBBF24), // Amber
      const Color(0xFFFB7185), // Rose
    ];
    final barHeights = [45.0, 68.0, 32.0, 52.0];

    for (int i = 0; i < 4; i++) {
      final bx = (cx - 55) + (i * 28.0);
      final h = barHeights[i];
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, cy + 45 - h, 18, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(barRect, Paint()..color = barColors[i]);
      canvas.drawRRect(barRect, stroke..strokeWidth = 1.8);
    }
    stroke.strokeWidth = 2.4;

    // Stacked Gold Coins on the left
    for (int i = 0; i < 3; i++) {
      final coinY = cy + 42 - (i * 10.0);
      final coin = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 75, coinY), width: 34, height: 16),
        const Radius.circular(8),
      );
      canvas.drawRRect(coin, Paint()..color = const Color(0xFFFACC15));
      canvas.drawRRect(coin, stroke);
    }

    // Large Magnifying Glass
    final magCenter = Offset(cx + 38, cy - 10);
    // Handle
    final handle = Path()
      ..moveTo(magCenter.dx + 26, magCenter.dy + 26)
      ..lineTo(magCenter.dx + 52, magCenter.dy + 52)
      ..lineTo(magCenter.dx + 44, magCenter.dy + 60)
      ..lineTo(magCenter.dx + 18, magCenter.dy + 34)
      ..close();
    canvas.drawPath(handle, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawPath(handle, stroke);

    // Glass Rim & Lens
    canvas.drawCircle(magCenter, 34, Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.6));
    canvas.drawCircle(magCenter, 34, stroke);
    canvas.drawCircle(magCenter, 28, stroke..strokeWidth = 1.6);
    stroke.strokeWidth = 2.4;

    // Glass Gleam
    canvas.drawArc(
      Rect.fromCircle(center: magCenter, radius: 22),
      -math.pi * 0.8,
      math.pi * 0.45,
      false,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Scene 3: Rocket blasting off with piggy bank & target
  void _drawLevelUpScene(Canvas canvas, double cx, double cy) {
    final stroke = Paint()
      ..color = const Color(0xFF18181B)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillWhite = Paint()..color = Colors.white;

    // Rocket Body
    final rocketCenter = Offset(cx + 10, cy - 5);
    final rocket = Path()
      ..moveTo(rocketCenter.dx, rocketCenter.dy - 65) // Nose tip
      ..quadraticBezierTo(rocketCenter.dx + 34, rocketCenter.dy - 20, rocketCenter.dx + 25, rocketCenter.dy + 35)
      ..lineTo(rocketCenter.dx - 25, rocketCenter.dy + 35)
      ..quadraticBezierTo(rocketCenter.dx - 34, rocketCenter.dy - 20, rocketCenter.dx, rocketCenter.dy - 65)
      ..close();
    canvas.drawPath(rocket, fillWhite);
    canvas.drawPath(rocket, stroke);

    // Red Nose Cone
    final nose = Path()
      ..moveTo(rocketCenter.dx, rocketCenter.dy - 65)
      ..quadraticBezierTo(rocketCenter.dx + 18, rocketCenter.dy - 40, rocketCenter.dx + 16, rocketCenter.dy - 35)
      ..lineTo(rocketCenter.dx - 16, rocketCenter.dy - 35)
      ..quadraticBezierTo(rocketCenter.dx - 18, rocketCenter.dy - 40, rocketCenter.dx, rocketCenter.dy - 65)
      ..close();
    canvas.drawPath(nose, Paint()..color = const Color(0xFFF43F5E));
    canvas.drawPath(nose, stroke);

    // Rocket Fins
    final finLeft = Path()
      ..moveTo(rocketCenter.dx - 25, rocketCenter.dy + 15)
      ..lineTo(rocketCenter.dx - 48, rocketCenter.dy + 42)
      ..lineTo(rocketCenter.dx - 25, rocketCenter.dy + 35)
      ..close();
    canvas.drawPath(finLeft, Paint()..color = const Color(0xFF06B6D4));
    canvas.drawPath(finLeft, stroke);

    final finRight = Path()
      ..moveTo(rocketCenter.dx + 25, rocketCenter.dy + 15)
      ..lineTo(rocketCenter.dx + 48, rocketCenter.dy + 42)
      ..lineTo(rocketCenter.dx + 25, rocketCenter.dy + 35)
      ..close();
    canvas.drawPath(finRight, Paint()..color = const Color(0xFF06B6D4));
    canvas.drawPath(finRight, stroke);

    // Porthole Window with $ coin
    canvas.drawCircle(Offset(rocketCenter.dx, rocketCenter.dy - 5), 16, Paint()..color = const Color(0xFFFACC15));
    canvas.drawCircle(Offset(rocketCenter.dx, rocketCenter.dy - 5), 16, stroke);
    // Currency icon in porthole
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\$',
        style: TextStyle(color: Color(0xFF18181B), fontSize: 16, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(rocketCenter.dx - 5.5, rocketCenter.dy - 15));

    // Flame Trail at Bottom
    final flameOuter = Path()
      ..moveTo(rocketCenter.dx - 18, rocketCenter.dy + 35)
      ..quadraticBezierTo(rocketCenter.dx, rocketCenter.dy + 72, rocketCenter.dx + 18, rocketCenter.dy + 35)
      ..close();
    canvas.drawPath(flameOuter, Paint()..color = const Color(0xFFF97316));
    canvas.drawPath(flameOuter, stroke);

    final flameInner = Path()
      ..moveTo(rocketCenter.dx - 9, rocketCenter.dy + 35)
      ..quadraticBezierTo(rocketCenter.dx, rocketCenter.dy + 56, rocketCenter.dx + 9, rocketCenter.dy + 35)
      ..close();
    canvas.drawPath(flameInner, Paint()..color = const Color(0xFFFACC15));

    // Target Bullseye on the left
    final targetCenter = Offset(cx - 70, cy + 30);
    canvas.drawCircle(targetCenter, 22, Paint()..color = const Color(0xFFF43F5E));
    canvas.drawCircle(targetCenter, 22, stroke);
    canvas.drawCircle(targetCenter, 15, fillWhite);
    canvas.drawCircle(targetCenter, 15, stroke);
    canvas.drawCircle(targetCenter, 7, Paint()..color = const Color(0xFFF43F5E));
  }

  /// Scene 4: Smart Brain mascot with glasses, idea bulb, and checklist
  void _drawBrainClarityScene(Canvas canvas, double cx, double cy) {
    final stroke = Paint()
      ..color = const Color(0xFF18181B)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillWhite = Paint()..color = Colors.white;

    // Glowing Lightbulb on top right
    final bulbCenter = Offset(cx + 65, cy - 45);
    canvas.drawCircle(bulbCenter, 18, Paint()..color = const Color(0xFFFDE047));
    canvas.drawCircle(bulbCenter, 18, stroke);
    // Base of bulb
    final bulbBase = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(bulbCenter.dx, bulbCenter.dy + 20), width: 14, height: 8),
      const Radius.circular(2),
    );
    canvas.drawRRect(bulbBase, stroke);
    // Glow rays
    canvas.drawLine(Offset(bulbCenter.dx, bulbCenter.dy - 24), Offset(bulbCenter.dx, bulbCenter.dy - 32), stroke);
    canvas.drawLine(Offset(bulbCenter.dx + 24, bulbCenter.dy), Offset(bulbCenter.dx + 32, bulbCenter.dy), stroke);
    canvas.drawLine(Offset(bulbCenter.dx - 24, bulbCenter.dy), Offset(bulbCenter.dx - 32, bulbCenter.dy), stroke);

    // Brain Center Mascot
    final brainCenter = Offset(cx - 15, cy + 5);
    final brainColor = Paint()..color = const Color(0xFFF9A8D4);

    // Left and Right hemisphere lobes
    canvas.drawCircle(Offset(brainCenter.dx - 24, brainCenter.dy - 12), 24, brainColor);
    canvas.drawCircle(Offset(brainCenter.dx - 24, brainCenter.dy - 12), 24, stroke);
    canvas.drawCircle(Offset(brainCenter.dx + 24, brainCenter.dy - 12), 24, brainColor);
    canvas.drawCircle(Offset(brainCenter.dx + 24, brainCenter.dy - 12), 24, stroke);
    canvas.drawCircle(Offset(brainCenter.dx - 18, brainCenter.dy + 16), 22, brainColor);
    canvas.drawCircle(Offset(brainCenter.dx - 18, brainCenter.dy + 16), 22, stroke);
    canvas.drawCircle(Offset(brainCenter.dx + 18, brainCenter.dy + 16), 22, brainColor);
    canvas.drawCircle(Offset(brainCenter.dx + 18, brainCenter.dy + 16), 22, stroke);

    // Brain glasses
    final leftGlass = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(brainCenter.dx - 16, brainCenter.dy), width: 22, height: 18),
      const Radius.circular(6),
    );
    final rightGlass = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(brainCenter.dx + 16, brainCenter.dy), width: 22, height: 18),
      const Radius.circular(6),
    );
    canvas.drawRRect(leftGlass, fillWhite);
    canvas.drawRRect(leftGlass, stroke);
    canvas.drawRRect(rightGlass, fillWhite);
    canvas.drawRRect(rightGlass, stroke);
    canvas.drawLine(Offset(brainCenter.dx - 5, brainCenter.dy), Offset(brainCenter.dx + 5, brainCenter.dy), stroke);

    // Smile
    canvas.drawArc(
      Rect.fromCircle(center: Offset(brainCenter.dx, brainCenter.dy + 16), radius: 6),
      0,
      math.pi,
      false,
      stroke..strokeWidth = 2.0,
    );
    stroke.strokeWidth = 2.4;

    // Mini Checklist tablet on the right
    final tablet = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 65, cy + 30), width: 44, height: 58),
      const Radius.circular(8),
    );
    canvas.drawRRect(tablet, fillWhite);
    canvas.drawRRect(tablet, stroke);
    // Green checkmarks
    for (int i = 0; i < 3; i++) {
      final ty = cy + 14 + (i * 14.0);
      canvas.drawLine(Offset(cx + 52, ty), Offset(cx + 56, ty + 4), stroke..color = const Color(0xFF10B981));
      canvas.drawLine(Offset(cx + 56, ty + 4), Offset(cx + 62, ty - 3), stroke..color = const Color(0xFF10B981));
      canvas.drawLine(Offset(cx + 68, ty), Offset(cx + 80, ty), stroke..color = const Color(0xFFCBD5E1));
    }
    stroke.color = const Color(0xFF18181B);
  }

  /// Scene 5: Golden Trophy cup with savings stars and celebration banners
  void _drawBudgetWinningScene(Canvas canvas, double cx, double cy) {
    final stroke = Paint()
      ..color = const Color(0xFF18181B)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillGold = Paint()..color = const Color(0xFFFBBF24);
    final fillWhite = Paint()..color = Colors.white;

    final cupCenter = Offset(cx, cy + 5);

    // Trophy Base
    final baseBottom = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cupCenter.dx, cupCenter.dy + 62), width: 78, height: 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(baseBottom, Paint()..color = const Color(0xFF78350F));
    canvas.drawRRect(baseBottom, stroke);

    final stem = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cupCenter.dx, cupCenter.dy + 45), width: 22, height: 22),
      const Radius.circular(3),
    );
    canvas.drawRRect(stem, fillGold);
    canvas.drawRRect(stem, stroke);

    // Trophy Bowl
    final bowl = Path()
      ..moveTo(cupCenter.dx - 48, cupCenter.dy - 35)
      ..lineTo(cupCenter.dx + 48, cupCenter.dy - 35)
      ..quadraticBezierTo(cupCenter.dx + 42, cupCenter.dy + 34, cupCenter.dx, cupCenter.dy + 35)
      ..quadraticBezierTo(cupCenter.dx - 42, cupCenter.dy + 34, cupCenter.dx - 48, cupCenter.dy - 35)
      ..close();
    canvas.drawPath(bowl, fillGold);
    canvas.drawPath(bowl, stroke);

    // Handles on Left & Right
    final handleLeft = Path()
      ..moveTo(cupCenter.dx - 45, cupCenter.dy - 20)
      ..cubicTo(cupCenter.dx - 75, cupCenter.dy - 25, cupCenter.dx - 75, cupCenter.dy + 15, cupCenter.dx - 32, cupCenter.dy + 18);
    canvas.drawPath(handleLeft, stroke..strokeWidth = 3.2);

    final handleRight = Path()
      ..moveTo(cupCenter.dx + 45, cupCenter.dy - 20)
      ..cubicTo(cupCenter.dx + 75, cupCenter.dy - 25, cupCenter.dx + 75, cupCenter.dy + 15, cupCenter.dx + 32, cupCenter.dy + 18);
    canvas.drawPath(handleRight, stroke..strokeWidth = 3.2);
    stroke.strokeWidth = 2.4;

    // Star in Center of Bowl
    _drawSparkleStar(canvas, Offset(cupCenter.dx, cupCenter.dy - 2), 16, fillWhite.color);

    // Rising coins overflowing
    for (int i = 0; i < 3; i++) {
      final coinPos = Offset(cupCenter.dx - 22 + (i * 22.0), cupCenter.dy - 44);
      canvas.drawCircle(coinPos, 10, fillGold);
      canvas.drawCircle(coinPos, 10, stroke);
    }
  }

  /// Draws a stylized jigsaw puzzle piece with diagonal hatch stripes
  void _drawPuzzlePiece(Canvas canvas, Offset center, double size, Color fillColor) {
    final stroke = Paint()
      ..color = const Color(0xFF18181B)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()..color = fillColor;

    final hs = size / 2;
    final r = size * 0.22;

    // Jigsaw path with rounded outer tabs and indentation
    final path = Path()
      ..moveTo(center.dx - hs, center.dy - hs)
      ..lineTo(center.dx - r, center.dy - hs)
      ..arcToPoint(Offset(center.dx + r, center.dy - hs), radius: Radius.circular(r), clockwise: true)
      ..lineTo(center.dx + hs, center.dy - hs)
      ..lineTo(center.dx + hs, center.dy - r)
      ..arcToPoint(Offset(center.dx + hs, center.dy + r), radius: Radius.circular(r), clockwise: false)
      ..lineTo(center.dx + hs, center.dy + hs)
      ..lineTo(center.dx + r, center.dy + hs)
      ..arcToPoint(Offset(center.dx - r, center.dy + hs), radius: Radius.circular(r), clockwise: true)
      ..lineTo(center.dx - hs, center.dy + hs)
      ..close();

    // Fill puzzle body
    canvas.drawPath(path, fill);

    // Clip to path and draw diagonal hatch stripes
    canvas.save();
    canvas.clipPath(path);
    final hatch = Paint()
      ..color = const Color(0xFF18181B)
      ..strokeWidth = 2.0;

    for (double i = -size; i < size * 2; i += 7.0) {
      canvas.drawLine(
        Offset(center.dx - hs + i, center.dy - hs),
        Offset(center.dx - hs + i + size, center.dy + hs),
        hatch,
      );
    }
    canvas.restore();

    // Outline
    canvas.drawPath(path, stroke);
  }

  /// 4-point yellow sparkle star
  void _drawSparkleStar(Canvas canvas, Offset center, double size, Color fillColor) {
    final fill = Paint()..color = fillColor;
    final stroke = Paint()
      ..color = const Color(0xFF18181B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final r = size / 2;
    final inR = r * 0.32;

    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * (math.pi / 2) - math.pi / 2;
      final nextAngle = angle + (math.pi / 4);

      if (i == 0) {
        path.moveTo(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      } else {
        path.lineTo(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      }
      path.lineTo(center.dx + inR * math.cos(nextAngle), center.dy + inR * math.sin(nextAngle));
    }
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  /// Hollow circle doodle
  void _drawHollowCircle(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF18181B)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant OnboardingIllustrationPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.isDark != isDark;
  }
}
