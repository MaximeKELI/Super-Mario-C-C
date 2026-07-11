import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/models.dart';
import '../data/save_service.dart';
import '../theme/mario_theme.dart';
import 'widgets/parallax_sky.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  List<HighScore> scores = [];

  @override
  void initState() {
    super.initState();
    HighScoreService().load().then((s) {
      if (mounted) setState(() => scores = s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParallaxSky(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('HIGH SCORES', style: Theme.of(context).textTheme.displayMedium),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: scores.isEmpty
                      ? const Center(child: Text('No scores yet — go make history!'))
                      : ListView.builder(
                          itemCount: scores.length,
                          itemBuilder: (context, i) {
                            final s = scores[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: i == 0 ? MarioColors.yellow : Colors.white70,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: i == 0 ? MarioColors.yellow : MarioColors.blue,
                                    child: Text('${i + 1}',
                                        style: const TextStyle(fontWeight: FontWeight.w900)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(s.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800, fontSize: 16)),
                                  ),
                                  Text('${s.score}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: MarioColors.red,
                                          fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text('L${s.level}',
                                      style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ).animate().fadeIn(delay: (40 * i).ms).slideX(begin: 0.08);
                          },
                        ),
                ),
                const SizedBox(height: 8),
                PremiumButton(label: 'BACK', color: MarioColors.green, onPressed: widget.onBack),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
