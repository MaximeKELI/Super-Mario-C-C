import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models.dart';
import '../../data/save_service.dart';
import '../../theme/mario_theme.dart';
import 'widgets/parallax_sky.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({
    super.key,
    required this.onNewGame,
    required this.onLoadGame,
    required this.onHighScores,
    required this.onStats,
  });

  final void Function(Difficulty d) onNewGame;
  final VoidCallback onLoadGame;
  final VoidCallback onHighScores;
  final VoidCallback onStats;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Difficulty _diff = Difficulty.normal;
  bool _hasSave = false;

  @override
  void initState() {
    super.initState();
    SaveService().hasSave().then((v) {
      if (mounted) setState(() => _hasSave = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxSky(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Center(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    height: 140,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      curve: Curves.elasticOut,
                      duration: 900.ms,
                    )
                    .then()
                    .moveY(begin: 0, end: -10, duration: 800.ms, curve: Curves.easeInOut)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.06, 1.06),
                      duration: 800.ms,
                    ),
                const SizedBox(height: 6),
                Center(
                  child: Image.asset(
                    'assets/images/Mario_clean.webp',
                    height: 72,
                    filterQuality: FilterQuality.none,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  'SUPER\nMARIO',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(height: 0.95),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
                const SizedBox(height: 8),
                Text(
                  'Classic juice · 10 worlds · premium feel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: MarioColors.dark.withValues(alpha: 0.75),
                      ),
                ).animate().fadeIn(delay: 200.ms),
                const Spacer(),
                _diffChipRow(),
                const SizedBox(height: 20),
                PremiumButton(
                  label: 'NEW GAME',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => widget.onNewGame(_diff),
                )
                    .animate()
                    .fadeIn(delay: 250.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutBack),
                const SizedBox(height: 12),
                if (_hasSave)
                  PremiumButton(
                    label: 'CONTINUE',
                    icon: Icons.save_rounded,
                    color: MarioColors.blue,
                    onPressed: widget.onLoadGame,
                  ).animate().fadeIn(delay: 320.ms),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        label: 'SCORES',
                        icon: Icons.emoji_events_rounded,
                        color: MarioColors.yellow,
                        onPressed: widget.onHighScores,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumButton(
                        label: 'STATS',
                        icon: Icons.bar_chart_rounded,
                        color: MarioColors.green,
                        onPressed: widget.onStats,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _diffChipRow() {
    Widget chip(Difficulty d, String label) {
      final selected = _diff == d;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _diff = d),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected ? MarioColors.yellow : Colors.white.withValues(alpha: 0.55),
              border: Border.all(
                color: selected ? MarioColors.red : Colors.white70,
                width: 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: MarioColors.yellow.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: MarioColors.dark,
                fontSize: selected ? 15 : 13,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(Difficulty.easy, 'EASY'),
        const SizedBox(width: 8),
        chip(Difficulty.normal, 'NORMAL'),
        const SizedBox(width: 8),
        chip(Difficulty.hard, 'HARD'),
      ],
    ).animate().fadeIn(delay: 180.ms);
  }
}
