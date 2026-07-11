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
    Future.delayed(const Duration(milliseconds: 900), () {
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
                        .animate()
                        .scale(
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutBack,
                          duration: 450.ms,
                        )
                        .fadeIn(duration: 300.ms),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'SUPER MARIO',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 80.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOut),
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
                    .fadeIn(delay: 150.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
