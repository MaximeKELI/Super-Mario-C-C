import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models.dart';
import '../../data/save_service.dart';
import '../../theme/mario_theme.dart';
import 'responsive.dart';
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
    final r = Responsive.of(context);

    return Scaffold(
      body: ParallaxSky(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: r.sp(r.isLandscape ? 24 : 28),
              vertical: r.sp(r.isCompact ? 8 : 16),
            ),
            child: r.isLandscape && r.isCompact
                ? _landscapeCompact(r)
                : _portraitOrTall(r),
          ),
        ),
      ),
    );
  }

  Widget _brandBlock(Responsive r, {required bool compact}) {
    final logoH = compact ? r.sp(72) : r.sp(120);
    final marioH = compact ? r.sp(48) : r.sp(64);
    final titleSize = compact ? r.sp(34) : r.sp(48);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/app_logo.png',
          height: logoH,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 400.ms)
            .scale(
              begin: const Offset(0.5, 0.5),
              curve: Curves.elasticOut,
              duration: 900.ms,
            )
            .then()
            .moveY(begin: 0, end: compact ? -4 : -10, duration: 800.ms, curve: Curves.easeInOut)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.06, 1.06),
              duration: 800.ms,
            ),
        SizedBox(height: r.sp(4)),
        Image.asset(
          'assets/images/Mario_clean.webp',
          height: marioH,
          filterQuality: FilterQuality.none,
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: r.sp(4)),
        Text(
          compact ? 'SUPER MARIO' : 'SUPER\nMARIO',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                height: 0.95,
                fontSize: titleSize,
              ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
        if (!compact) ...[
          SizedBox(height: r.sp(6)),
          Text(
            'Classic juice · 10 worlds · premium feel',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: MarioColors.dark.withValues(alpha: 0.75),
                  fontSize: r.sp(14),
                ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ],
    );
  }

  Widget _actions(Responsive r, {required bool compact}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _diffChipRow(r),
        SizedBox(height: r.sp(compact ? 10 : 16)),
        PremiumButton(
          label: 'NEW GAME',
          icon: Icons.play_arrow_rounded,
          onPressed: () => widget.onNewGame(_diff),
        )
            .animate()
            .fadeIn(delay: 250.ms)
            .slideY(begin: 0.3, curve: Curves.easeOutBack),
        SizedBox(height: r.sp(8)),
        if (_hasSave)
          PremiumButton(
            label: 'CONTINUE',
            icon: Icons.save_rounded,
            color: MarioColors.blue,
            onPressed: widget.onLoadGame,
          ).animate().fadeIn(delay: 320.ms),
        if (_hasSave) SizedBox(height: r.sp(8)),
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
            SizedBox(width: r.sp(10)),
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
      ],
    );
  }

  Widget _landscapeCompact(Responsive r) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: _brandBlock(r, compact: true),
          ),
        ),
        SizedBox(width: r.sp(16)),
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: _actions(r, compact: true),
          ),
        ),
      ],
    );
  }

  Widget _portraitOrTall(Responsive r) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 1),
                  _brandBlock(r, compact: r.isCompact),
                  const Spacer(flex: 1),
                  _actions(r, compact: r.isCompact),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _diffChipRow(Responsive r) {
    Widget chip(Difficulty d, String label) {
      final selected = _diff == d;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _diff = d),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: EdgeInsets.symmetric(vertical: r.sp(r.isCompact ? 8 : 12)),
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
                fontSize: selected ? r.sp(14) : r.sp(12),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(Difficulty.easy, 'EASY'),
        SizedBox(width: r.sp(8)),
        chip(Difficulty.normal, 'NORMAL'),
        SizedBox(width: r.sp(8)),
        chip(Difficulty.hard, 'HARD'),
      ],
    ).animate().fadeIn(delay: 180.ms);
  }
}
