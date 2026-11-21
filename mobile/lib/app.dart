import 'dart:async';

import 'package:flutter/material.dart';

import 'audio/audio_service.dart';
import 'data/character.dart';
import 'data/models.dart';
import 'data/save_service.dart';
import 'theme/app_theme.dart';
import 'ui/game_screen.dart';
import 'ui/high_scores_screen.dart';
import 'ui/main_menu.dart';
import 'ui/splash_screen.dart';
import 'ui/statistics_screen.dart';

enum AppRoute { splash, menu, game, scores, stats }

class PipeLeapApp extends StatefulWidget {
  const PipeLeapApp({super.key});

  @override
  State<PipeLeapApp> createState() => _PipeLeapAppState();
}

class _PipeLeapAppState extends State<PipeLeapApp> {
  AppRoute route = AppRoute.splash;
  Difficulty difficulty = Difficulty.normal;
  PlayableCharacter character = PlayableCharacter.pip;
  SaveData? save;
  final _charPrefs = CharacterPrefs();

  @override
  void initState() {
    super.initState();
    unawaited(AudioService.instance.init());
    _charPrefs.load().then((c) {
      if (mounted) setState(() => character = c);
    });
  }

  Future<void> _selectCharacter(PlayableCharacter c) async {
    setState(() => character = c);
    await _charPrefs.save(c);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PipeLeap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(route),
          child: switch (route) {
            AppRoute.splash => SplashScreen(
                onDone: () => setState(() => route = AppRoute.menu),
              ),
            AppRoute.menu => MainMenuScreen(
                character: character,
                onCharacterChanged: _selectCharacter,
                onNewGame: (d) => setState(() {
                  difficulty = d;
                  save = null;
                  route = AppRoute.game;
                }),
                onLoadGame: () async {
                  final s = await SaveService().load();
                  if (!mounted) return;
                  if (s == null) return;
                  setState(() {
                    save = s;
                    difficulty = s.difficulty;
                    route = AppRoute.game;
                  });
                },
                onHighScores: () => setState(() => route = AppRoute.scores),
                onStats: () => setState(() => route = AppRoute.stats),
              ),
            AppRoute.game => GameScreen(
                difficulty: difficulty,
                character: character,
                save: save,
                onExit: () => setState(() {
                  save = null;
                  route = AppRoute.menu;
                }),
              ),
            AppRoute.scores => HighScoresScreen(
                onBack: () => setState(() => route = AppRoute.menu),
              ),
            AppRoute.stats => StatisticsScreen(
                onBack: () => setState(() => route = AppRoute.menu),
              ),
          },
        ),
      ),
    );
  }
}
