import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models.dart';
import '../../theme/mario_theme.dart';
import '../../game/mario_game.dart';
import 'enter_name_sheet.dart';
import 'pause_overlay.dart';
import 'widgets/parallax_sky.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.difficulty,
    this.save,
    required this.onExit,
  });

  final Difficulty difficulty;
  final SaveData? save;
  final VoidCallback onExit;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MarioGame game;
  int _coinPulse = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    game = MarioGame(
      difficulty: widget.difficulty,
      initialSave: widget.save,
      onExitToMenu: widget.onExit,
      onNeedName: (score) => EnterNameSheet.show(context, score),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'hud': (context, MarioGame g) => _GameHud(
                game: g,
                coinPulseKey: _coinPulse,
                onPause: () {
                  g.togglePause();
                  setState(() {});
                },
              ),
          'controls': (context, MarioGame g) => _VirtualControls(game: g),
          'pause': (context, MarioGame g) => PauseOverlay(
                game: g,
                onResume: () {
                  g.togglePause();
                  setState(() {});
                },
                onExit: widget.onExit,
              ),
          'levelClear': (context, MarioGame g) => const _LevelClearBanner(),
          'gameOver': (context, MarioGame g) => _GameOverOverlay(
                score: g.score,
                onMenu: widget.onExit,
              ),
        },
        initialActiveOverlays: const ['hud', 'controls'],
      ),
    );
  }
}

class _GameHud extends StatelessWidget {
  const _GameHud({
    required this.game,
    required this.onPause,
    required this.coinPulseKey,
  });
  final MarioGame game;
  final VoidCallback onPause;
  final int coinPulseKey;

  @override
  Widget build(BuildContext context) {
    // refresh overlays based on phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final overlays = game.overlays;
      if (game.phase == PlayPhase.paused && !overlays.isActive('pause')) {
        overlays.add('pause');
      } else if (game.phase != PlayPhase.paused && overlays.isActive('pause')) {
        overlays.remove('pause');
      }
      if (game.phase == PlayPhase.levelClear && !overlays.isActive('levelClear')) {
        overlays.add('levelClear');
      } else if (game.phase != PlayPhase.levelClear && overlays.isActive('levelClear')) {
        overlays.remove('levelClear');
      }
      if (game.phase == PlayPhase.gameOver && !overlays.isActive('gameOver')) {
        overlays.add('gameOver');
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          children: [
            _HudPill(icon: Icons.favorite, label: 'x${game.lives}', color: MarioColors.red),
            const SizedBox(width: 8),
            _HudPill(
              icon: Icons.monetization_on,
              label: '${game.coins}',
              color: MarioColors.yellow,
            ).animate(key: ValueKey(game.coins)).scale(
                  begin: const Offset(1.25, 1.25),
                  end: const Offset(1, 1),
                  duration: 280.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(width: 8),
            _HudPill(icon: Icons.star, label: '${game.score}', color: MarioColors.blue),
            const Spacer(),
            _HudPill(
              icon: Icons.flag,
              label: 'WORLD ${game.currentLevel}',
              color: MarioColors.green,
            ),
            const SizedBox(width: 8),
            _MiniMap(game: game),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onPause,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
              ),
              icon: const Icon(Icons.pause_rounded, color: MarioColors.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: MarioColors.dark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap({required this.game});
  final MarioGame game;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(90, 28),
      painter: _MiniMapPainter(game),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  _MiniMapPainter(this.game);
  final MarioGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8));
    canvas.drawRRect(r, Paint()..color = Colors.black.withValues(alpha: 0.35));
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final progress = (game.player.position.x / game.levelEndX).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(8 + progress * (size.width - 16), size.height / 2),
      5,
      Paint()..color = MarioColors.red,
    );
    canvas.drawCircle(
      Offset(size.width - 8, size.height / 2),
      4,
      Paint()..color = MarioColors.yellow,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) => true;
}

class _VirtualControls extends StatelessWidget {
  const _VirtualControls({required this.game});
  final MarioGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                _CtrlBtn(
                  icon: Icons.arrow_back_rounded,
                  onDown: () => game.ctrlLeft = true,
                  onUp: () => game.ctrlLeft = false,
                ),
                const SizedBox(width: 12),
                _CtrlBtn(
                  icon: Icons.arrow_forward_rounded,
                  onDown: () => game.ctrlRight = true,
                  onUp: () => game.ctrlRight = false,
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _CtrlBtn(
                  icon: Icons.arrow_downward_rounded,
                  label: 'PIPE',
                  color: MarioColors.pipe,
                  onDown: () => game.ctrlPipe = true,
                  onUp: () => game.ctrlPipe = false,
                ),
                const SizedBox(width: 10),
                _CtrlBtn(
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF6A00),
                  onDown: () => game.ctrlFire = true,
                  onUp: () => game.ctrlFire = false,
                ),
                const SizedBox(width: 10),
                _CtrlBtn(
                  icon: Icons.keyboard_arrow_up_rounded,
                  color: MarioColors.yellow,
                  big: true,
                  onDown: () => game.ctrlJump = true,
                  onUp: () => game.ctrlJump = false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  const _CtrlBtn({
    required this.icon,
    required this.onDown,
    required this.onUp,
    this.color = MarioColors.blue,
    this.big = false,
    this.label,
  });
  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final Color color;
  final bool big;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final size = big ? 72.0 : 58.0;
    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color.lerp(color, Colors.white, 0.35)!, color],
          ),
          border: Border.all(color: Colors.white70, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: big ? 36 : 28),
            if (label != null)
              Text(
                label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LevelClearBanner extends StatelessWidget {
  const _LevelClearBanner();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [MarioColors.yellow, MarioColors.red],
          ),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: MarioColors.yellow.withValues(alpha: 0.55),
              blurRadius: 28,
            ),
          ],
        ),
        child: Text(
          'LEVEL CLEAR!',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
              ),
        ),
      )
          .animate()
          .scale(begin: const Offset(0.4, 0.4), curve: Curves.elasticOut, duration: 800.ms)
          .fadeIn(),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({required this.score, required this.onMenu});
  final int score;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('GAME OVER', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text('Score $score', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: MarioColors.cream)),
            const SizedBox(height: 20),
            PremiumButton(label: 'MENU', onPressed: onMenu),
          ],
        ).animate().fadeIn().slideY(begin: 0.2),
      ),
    );
  }
}
