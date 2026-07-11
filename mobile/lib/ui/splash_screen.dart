import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/mario_theme.dart';
import 'widgets/parallax_sky.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxSky(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: AnimatedBuilder(
                    animation: _orbit,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          for (var i = 0; i < 12; i++)
                            Transform.translate(
                              offset: Offset(
                                cos(_orbit.value * pi * 2 + i) * (100 + (i % 3) * 12),
                                sin(_orbit.value * pi * 2 + i * 1.3) * (80 + (i % 2) * 16),
                              ),
                              child: Transform.rotate(
                                angle: _orbit.value * pi * 2 + i,
                                child: Icon(
                                  Icons.star_rounded,
                                  color: MarioColors.yellow.withValues(alpha: 0.9),
                                  size: 20.0 + (i % 4) * 6,
                                ),
                              ),
                            ),
                          child!,
                        ],
                      );
                    },
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [MarioColors.yellow, MarioColors.red],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: MarioColors.red.withValues(alpha: 0.55),
                            blurRadius: 40,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: MarioColors.yellow.withValues(alpha: 0.45),
                            blurRadius: 28,
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/Mario.gif',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.15, 0.15),
                          end: const Offset(1, 1),
                          curve: Curves.elasticOut,
                          duration: 1200.ms,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.08, 1.08),
                          duration: 700.ms,
                          curve: Curves.easeInOut,
                        )
                        .shake(hz: 2.5, rotation: 0.03, duration: 600.ms),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'SUPER MARIO',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.4, curve: Curves.easeOutBack),
                const SizedBox(height: 8),
                Text(
                  'MOBILE PREMIUM',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: MarioColors.yellow,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w900,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms)
                    .shimmer(duration: 1600.ms, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
