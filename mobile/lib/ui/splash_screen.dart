import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../game/gif_loader.dart';
import '../../theme/mario_theme.dart';
import 'responsive.dart';
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
  bool _assetsReady = false;
  bool _minTimeDone = false;
  bool _finishScheduled = false;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _bootstrap();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _minTimeDone = true;
      _tryFinish();
    });
  }

  Future<void> _bootstrap() async {
    await GifLoader.preloadMario();
    if (!mounted) return;
    setState(() => _assetsReady = true);
    _tryFinish();
  }

  void _tryFinish() {
    if (_assetsReady && _minTimeDone && mounted && !_finishScheduled) {
      _finishScheduled = true;
      widget.onDone();
    }
  }

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final stage = (r.shortest * 0.55).clamp(140.0, 300.0);
    final logo = stage * 0.7;
    final orbitX = stage * 0.37;
    final orbitY = stage * 0.3;

    return Scaffold(
      body: ParallaxSky(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: r.sp(16), vertical: r.sp(8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: stage,
                    height: stage,
                    child: AnimatedBuilder(
                      animation: _orbit,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            for (var i = 0; i < 12; i++)
                              Transform.translate(
                                offset: Offset(
                                  cos(_orbit.value * pi * 2 + i) * (orbitX + (i % 3) * 8),
                                  sin(_orbit.value * pi * 2 + i * 1.3) * (orbitY + (i % 2) * 10),
                                ),
                                child: Transform.rotate(
                                  angle: _orbit.value * pi * 2 + i,
                                  child: Icon(
                                    Icons.star_rounded,
                                    color: MarioColors.yellow.withValues(alpha: 0.9),
                                    size: (14.0 + (i % 4) * 4) * r.scale.clamp(0.8, 1.1),
                                  ),
                                ),
                              ),
                            child!,
                          ],
                        );
                      },
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: logo,
                        height: logo,
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
                  SizedBox(height: r.sp(12)),
                  Text(
                    'SUPER MARIO',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: r.sp(r.isCompact ? 36 : 52),
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 80.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOut),
                  SizedBox(height: r.sp(6)),
                  Text(
                    _assetsReady ? 'MOBILE PREMIUM' : 'CHARGEMENT...',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: MarioColors.yellow,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w900,
                          fontSize: r.sp(16),
                        ),
                  ).animate().fadeIn(delay: 150.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
