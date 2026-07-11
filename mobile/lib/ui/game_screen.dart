import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models.dart';
import '../../theme/mario_theme.dart';
import '../../game/mario_game.dart';
import 'enter_name_sheet.dart';
import 'pause_overlay.dart';
import 'responsive.dart';
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
  Timer? _hudTick;
  final FocusNode _gameFocus = FocusNode();

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
    _hudTick = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _hudTick?.cancel();
    _gameFocus.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarioColors.skyTop,
      body: GameWidget(
        game: game,
        autofocus: true,
        focusNode: _gameFocus,
        overlayBuilderMap: {
          'hud': (context, MarioGame g) => _GameHud(
                game: g,
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
  });
  final MarioGame game;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
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

    final r = Responsive.of(context);
    final showKeyboardHint = !r.isCompact &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(r.sp(10), r.sp(6), r.sp(10), 0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - r.sp(20)),
                child: Row(
                  children: [
                    _HudPill(
                      icon: Icons.favorite,
                      label: 'x${game.lives}',
                      color: MarioColors.red,
                      scale: r.scale,
                    ),
                    SizedBox(width: r.sp(6)),
                    _HudPill(
                      icon: Icons.monetization_on,
                      label: '${game.coins}',
                      color: MarioColors.yellow,
                      scale: r.scale,
                    ).animate(key: ValueKey(game.coins)).scale(
                          begin: const Offset(1.25, 1.25),
                          end: const Offset(1, 1),
                          duration: 280.ms,
                          curve: Curves.easeOutBack,
                        ),
                    SizedBox(width: r.sp(6)),
                    _HudPill(
                      icon: Icons.star,
                      label: '${game.score}',
                      color: MarioColors.blue,
                      scale: r.scale,
                    ),
                    SizedBox(width: r.sp(8)),
                    _HudPill(
                      icon: Icons.flag,
                      label: r.isNarrow ? 'W${game.currentLevel}' : 'WORLD ${game.currentLevel}',
                      color: MarioColors.green,
                      scale: r.scale,
                    ),
                    if (!r.isCompact) ...[
                      SizedBox(width: r.sp(6)),
                      _MiniMap(game: game, scale: r.scale),
                    ],
                    SizedBox(width: r.sp(4)),
                    IconButton(
                      onPressed: onPause,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        minimumSize: Size(r.sp(40), r.sp(40)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(Icons.pause_rounded, color: MarioColors.dark, size: r.sp(22)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showKeyboardHint) const _KeyboardHint(),
        ],
      ),
    );
  }
}

class _KeyboardHint extends StatelessWidget {
  const _KeyboardHint();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 48),
          child: Text(
            '← → déplacer  ·  ↑/Espace saut  ·  ↓ pipe  ·  X feu  ·  P pause',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({
    required this.icon,
    required this.label,
    required this.color,
    this.scale = 1,
  });
  final IconData icon;
  final String label;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: color, width: 1.5 * scale),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 6 * scale, offset: Offset(0, 2 * scale)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14 * scale, color: color),
          SizedBox(width: 3 * scale),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: MarioColors.dark,
              fontSize: 12 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap({required this.game, this.scale = 1});
  final MarioGame game;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(72 * scale, 22 * scale),
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
    final r = Responsive.of(context);
    final gap = r.sp(8);
    final pad = r.sp(r.isCompact ? 10 : 16);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                _CtrlBtn(
                  icon: Icons.arrow_back_rounded,
                  scale: r.scale,
                  onDown: () => game.ctrlLeft = true,
                  onUp: () => game.ctrlLeft = false,
                ),
                SizedBox(width: gap),
                _CtrlBtn(
                  icon: Icons.arrow_forward_rounded,
                  scale: r.scale,
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
                  label: r.isCompact ? null : 'PIPE',
                  color: MarioColors.pipe,
                  scale: r.scale,
                  onDown: () => game.ctrlPipe = true,
                  onUp: () => game.ctrlPipe = false,
                ),
                SizedBox(width: gap),
                _CtrlBtn(
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF6A00),
                  scale: r.scale,
                  onDown: () => game.ctrlFire = true,
                  onUp: () => game.ctrlFire = false,
                ),
                SizedBox(width: gap),
                _CtrlBtn(
                  icon: Icons.keyboard_arrow_up_rounded,
                  color: MarioColors.yellow,
                  big: true,
                  scale: r.scale,
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
    this.scale = 1,
  });
  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final Color color;
  final bool big;
  final String? label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = (big ? 64.0 : 50.0) * scale;
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
          border: Border.all(color: Colors.white70, width: 2.5 * scale),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: (big ? 30 : 24) * scale),
            if (label != null)
              Text(
                label!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8 * scale,
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
    final r = Responsive.of(context);
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: EdgeInsets.symmetric(horizontal: r.sp(28), vertical: r.sp(16)),
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
                  fontSize: r.sp(36),
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2)),
                    Shadow(color: MarioColors.yellow, blurRadius: 18),
                  ],
                ),
          ),
        ),
      )
          .animate()
          .scale(begin: const Offset(0.2, 0.2), curve: Curves.elasticOut, duration: 900.ms)
          .fadeIn()
          .then()
          .shake(hz: 3, offset: 0.04, duration: 500.ms)
          .shimmer(duration: 1200.ms, color: Colors.white),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({required this.score, required this.onMenu});
  final int score;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Container(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.sp(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: r.sp(32)),
              ),
              SizedBox(height: r.sp(8)),
              Text(
                'Score $score',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: MarioColors.cream,
                      fontSize: r.sp(18),
                    ),
              ),
              SizedBox(height: r.sp(16)),
              PremiumButton(label: 'MENU', onPressed: onMenu),
            ],
          ).animate().fadeIn().slideY(begin: 0.2),
        ),
      ),
    );
  }
}
