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
                  width: 300,
                  height: 300,
                  child: AnimatedBuilder(
                    animation: _orbit,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          for (var i = 0; i < 12; i++)
                            Transform.translate(
                              offset: Offset(
                                cos(_orbit.value * pi * 2 + i) * (110 + (i % 3) * 12),
                                sin(_orbit.value * pi * 2 + i * 1.3) * (90 + (i % 2) * 16),
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
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 210,
                      height: 210,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
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
                          end: const Offset(1.06, 1.06),
                          duration: 700.ms,
                          curve: Curves.easeInOut,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
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
