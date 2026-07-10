import 'package:flutter/material.dart';

import 'audio/audio_service.dart';
import 'data/models.dart';
import 'data/save_service.dart';
import 'theme/mario_theme.dart';
import 'ui/game_screen.dart';
import 'ui/high_scores_screen.dart';
import 'ui/main_menu.dart';
import 'ui/splash_screen.dart';
import 'ui/statistics_screen.dart';

enum AppRoute { splash, menu, game, scores, stats }

class MarioApp extends StatefulWidget {
  const MarioApp({super.key});

  @override
  State<MarioApp> createState() => _MarioAppState();
}

class _MarioAppState extends State<MarioApp> {
  AppRoute route = AppRoute.splash;
  Difficulty difficulty = Difficulty.normal;
  SaveData? save;

  @override
  void initState() {
    super.initState();
    AudioService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Mario Mobile',
      debugShowCheckedModeBanner: false,
      theme: MarioTheme.light,
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
                onNewGame: (d) => setState(() {
                  difficulty = d;
                  save = null;
                  route = AppRoute.game;
                }),
                onLoadGame: () async {
                  final s = await SaveService().load();
                  if (s != null) {
                    setState(() {
                      save = s;
                      difficulty = s.difficulty;
                      route = AppRoute.game;
                    });
                  }
                },
                onHighScores: () => setState(() => route = AppRoute.scores),
                onStats: () => setState(() => route = AppRoute.stats),
              ),
            AppRoute.game => GameScreen(
                difficulty: difficulty,
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
