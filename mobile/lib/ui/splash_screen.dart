import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/mario_theme.dart';
import '../widgets/parallax_sky.dart';

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
                  width: 220,
                  height: 220,
                  child: AnimatedBuilder(
                    animation: _orbit,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          for (var i = 0; i < 8; i++)
                            Transform.translate(
                              offset: Offset(
                                cos(_orbit.value * pi * 2 + i) * 90,
                                sin(_orbit.value * pi * 2 + i) * 70,
                              ),
                              child: Icon(
                                Icons.star_rounded,
                                color: MarioColors.yellow.withValues(alpha: 0.85),
                                size: 18 + (i % 3) * 4,
                              ),
                            ),
                          child!,
                        ],
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [MarioColors.yellow, MarioColors.red],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: MarioColors.red.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: const Icon(Icons.sports_esports, size: 56, color: Colors.white),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.2, 0.2),
                          end: const Offset(1, 1),
                          curve: Curves.elasticOut,
                          duration: 1100.ms,
                        )
                        .then()
                        .shake(hz: 2, rotation: 0.02),
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
