import 'dart:math';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  final Widget Function() next;
  const SplashScreen({super.key, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _enter; // bag pops in with a bounce
  late final Animation<double> _glow; // purple halo grows
  late final Animation<double> _shine; // light sweeps across the logo
  late final Animation<double> _exit; // Netflix-style zoom through

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // One controller, several Intervals = a timeline (0.0 -> 1.0)
    _enter = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    );
    _glow = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.15, 0.6, curve: Curves.easeOut),
    );
    _shine = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
    );
    _exit = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.85, 1.0, curve: Curves.easeInCubic),
    );

    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goHome();
    });
    _c.forward();
  }

void _goHome() {
  if (!mounted) return;
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => widget.next(),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final fadeIn = (_c.value / 0.12).clamp(0.0, 1.0).toDouble();
          final scale = (0.3 + 0.7 * _enter.value) * (1 + 7 * _exit.value);
          final opacity = fadeIn * (1 - _exit.value);

          return SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft purple glow behind the logo
                Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 220 * _glow.value,
                    height: 220 * _glow.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB366FF)
                              .withValues(alpha:  0.35 * _glow.value),
                          blurRadius: 120,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                 ),
                ),
            
                // Twinkling sparkles
                Opacity(
                  opacity: opacity,
                  child: CustomPaint(
                    size: const Size(360, 360),
                    painter: SparklePainter(progress: _c.value),
                  ),
                ),
            
                // The logo
                Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: ShaderMask(
                      blendMode: BlendMode.srcATop,
                      shaderCallback: (rect) => _shineShader(rect, _shine.value),
                      child: Image.asset(
                        'assets/images/mr_logo.png',
                        width: 240,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // A diagonal band of white light that travels across the logo as t: 0 -> 1.
  Shader _shineShader(Rect rect, double t) {
    final center = -0.3 + 1.6 * t; // starts and ends off-screen
    double clamp01(double v) => v.clamp(0.0, 1.0).toDouble();

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.transparent,
        Colors.white.withValues(alpha:  0.85),
        Colors.transparent,
      ],
      stops: [clamp01(center - 0.15), clamp01(center), clamp01(center + 0.15)],
    ).createShader(rect);
  }
}

/// Placeholder: replace with your real home screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Welcome to MR Store')));
  }
}

class SparklePainter extends CustomPainter {
  final double progress;
  SparklePainter({required this.progress});

  // (x, y) from the centre as a fraction of size, phase offset, radius
  static const _sparkles = [
    [-0.45, -0.25, 0.0, 9.0],
    [0.42, -0.42, 0.25, 7.0],
    [0.5, 0.15, 0.5, 10.0],
    [-0.55, 0.2, 0.75, 8.0],
    [0.2, 0.45, 0.4, 6.0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final s in _sparkles) {
      final pos = center + Offset(s[0] * size.width, s[1] * size.height);
      // sine wave -> 0..1 pulse, each sparkle offset by its phase
      final twinkle = (sin((progress * 2 * pi * 2) + s[2] * 2 * pi) + 1) / 2;
      // only appear once the logo has landed (after ~30% of the timeline)
      final appear = ((progress - 0.3) / 0.15).clamp(0.0, 1.0);
      final r = s[3] * twinkle * appear;
      if (r <= 0.1) continue;

      final paint = Paint()
        ..color = const Color(0xFFC77DFF).withOpacity(0.9 * twinkle * appear);

      // 4-point star
      final path = Path()
        ..moveTo(pos.dx, pos.dy - r)
        ..quadraticBezierTo(pos.dx, pos.dy, pos.dx + r, pos.dy)
        ..quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy + r)
        ..quadraticBezierTo(pos.dx, pos.dy, pos.dx - r, pos.dy)
        ..quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy - r)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SparklePainter old) => old.progress != progress;
}
