import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../audio/audio_service.dart';
import '../../game/pipeleap_game.dart';
import '../../theme/app_theme.dart';
import 'responsive.dart';
import 'widgets/parallax_sky.dart';

class PauseOverlay extends StatefulWidget {
  const PauseOverlay({
    super.key,
    required this.game,
    required this.onResume,
    required this.onExit,
  });

  final PipeLeapGame game;
  final VoidCallback onResume;
  final VoidCallback onExit;

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  bool options = false;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final maxW = (MediaQuery.sizeOf(context).width * 0.9).clamp(240.0, 360.0);

    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.sp(12)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Container(
              width: maxW,
              padding: EdgeInsets.all(r.sp(r.isCompact ? 16 : 24)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF8E7), Color(0xFFFFE08A)],
                ),
                border: Border.all(color: AppColors.red, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.red.withValues(alpha: 0.35),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: options ? _options() : _main(),
            ).animate().scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
          ),
        ),
      ),
    );
  }

  Widget _main() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('PAUSE', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.red)),
        const SizedBox(height: 20),
        PremiumButton(label: 'RESUME', color: AppColors.green, onPressed: widget.onResume),
        const SizedBox(height: 10),
        PremiumButton(
          label: 'OPTIONS',
          color: AppColors.blue,
          onPressed: () => setState(() => options = true),
        ),
        const SizedBox(height: 10),
        PremiumButton(
          label: 'SAVE',
          color: AppColors.yellow,
          onPressed: () async {
            await widget.game.saveGame();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game saved!')),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        PremiumButton(label: 'MENU', onPressed: widget.onExit),
      ],
    );
  }

  Widget _options() {
    final audio = AudioService.instance;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('OPTIONS', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text('Music', style: Theme.of(context).textTheme.titleLarge),
        Slider(
          value: audio.musicVolume,
          activeColor: AppColors.red,
          onChanged: (v) async {
            await audio.setMusicVolume(v);
            setState(() {});
          },
        ),
        Text('Sound', style: Theme.of(context).textTheme.titleLarge),
        Slider(
          value: audio.soundVolume,
          activeColor: AppColors.blue,
          onChanged: (v) async {
            await audio.setSoundVolume(v);
            setState(() {});
          },
        ),
        const SizedBox(height: 8),
        PremiumButton(
          label: 'BACK',
          color: AppColors.green,
          onPressed: () => setState(() => options = false),
        ),
      ],
    );
  }
}
