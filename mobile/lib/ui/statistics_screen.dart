import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/models.dart';
import '../data/save_service.dart';
import '../theme/mario_theme.dart';
import 'widgets/parallax_sky.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  GameStats stats = GameStats();

  @override
  void initState() {
    super.initState();
    StatsService().load().then((s) {
      if (mounted) setState(() => stats = s);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Play time', '${stats.totalPlayTime.toStringAsFixed(0)}s'),
      ('Enemies defeated', stats.enemiesKilled.toString()),
      ('Power-ups', stats.powerUpsCollected.toString()),
      ('Distance', stats.distanceTraveled.toStringAsFixed(0)),
      ('Coins lifetime', stats.totalCoinsCollected.toString()),
      ('Levels cleared', stats.levelsCompleted.toString()),
    ];
    return Scaffold(
      body: ParallaxSky(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('STATISTICS', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      for (var i = 0; i < rows.length; i++)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(rows[i].$1,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(
                                rows[i].$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: MarioColors.blue,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (50 * i).ms),
                    ],
                  ),
                ),
                PremiumButton(label: 'BACK', color: MarioColors.green, onPressed: widget.onBack),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
