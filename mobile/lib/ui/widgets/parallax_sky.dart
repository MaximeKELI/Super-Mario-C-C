import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/mario_theme.dart';
import '../responsive.dart';

class ParallaxSky extends StatefulWidget {
  const ParallaxSky({super.key, this.child});
  final Widget? child;

  @override
  State<ParallaxSky> createState() => _ParallaxSkyState();
}

class _ParallaxSkyState extends State<ParallaxSky>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 40))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return CustomPaint(
          painter: _SkyPainter(_c.value),
          child: widget.child,
        );
      },
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF049CD8),
            Color(0xFF5EC8F8),
            Color(0xFFB8ECFF),
            Color(0xFF8FDE7A),
          ],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(rect),
    );

    // hills
    final hill = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.62, size.width * 0.5, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.9, size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill, Paint()..color = MarioColors.green.withValues(alpha: 0.85));

    void cloud(double x, double y, double s) {
      final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 90 * s, height: 36 * s), paint);
      canvas.drawCircle(Offset(x - 22 * s, y), 22 * s, paint);
      canvas.drawCircle(Offset(x + 18 * s, y - 6 * s), 26 * s, paint);
    }

    for (var i = 0; i < 6; i++) {
      final base = (t * size.width * (0.15 + i * 0.04) + i * 180) % (size.width + 160);
      cloud(base - 80, 60.0 + i * 28 + sin(t * pi * 2 + i) * 8, 0.7 + (i % 3) * 0.2);
    }

    // floating coins sparkles
    final spark = Paint()..color = MarioColors.yellow.withValues(alpha: 0.55);
    for (var i = 0; i < 12; i++) {
      final x = (sin(t * pi * 2 + i) * 0.5 + 0.5) * size.width;
      final y = 40 + (i * 37 % size.height * 0.45);
      canvas.drawCircle(Offset(x, y), 2.5, spark);
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) => oldDelegate.t != t;
}

class PremiumButton extends StatefulWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = MarioColors.red,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final compact = r.isCompact;

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.86 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? r.sp(18) : 28,
            vertical: compact ? r.sp(10) : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(widget.color, Colors.white, 0.25)!,
                widget.color,
                Color.lerp(widget.color, Colors.black, 0.15)!,
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.55),
                blurRadius: _down ? 6 : (compact ? 12 : 22),
                offset: Offset(0, _down ? 1 : (compact ? 4 : 10)),
              ),
              BoxShadow(
                color: MarioColors.yellow.withValues(alpha: _down ? 0.2 : 0.5),
                blurRadius: compact ? 16 : 30,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: MarioColors.cream, size: compact ? r.sp(18) : 22),
                SizedBox(width: compact ? 6 : 10),
              ],
              Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: MarioColors.cream,
                      letterSpacing: 0.6,
                      fontSize: compact ? r.sp(16) : null,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1)),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

