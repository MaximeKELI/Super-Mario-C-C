import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  AudioService._();
  static final instance = AudioService._();

  final _bgm = AudioPlayer();
  final _sfx = AudioPlayer();
  double musicVolume = 0.7;
  double soundVolume = 0.9;
  bool _bgmPlaying = false;
  bool _ready = false;
  Completer<void>? _initCompleter;

  Future<void> init() async {
    if (_ready) return;
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();
    try {
      // Media player mode is more reliable for longer MP3 loops on mobile/desktop.
      await _bgm.setPlayerMode(PlayerMode.mediaPlayer);
      await _sfx.setPlayerMode(PlayerMode.mediaPlayer);
      await _bgm.setReleaseMode(ReleaseMode.loop);
      await _bgm.setVolume(musicVolume);
      await _sfx.setVolume(soundVolume);
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
      _ready = true;
      _initCompleter!.complete();
    } catch (e, st) {
      debugPrint('AudioService.init failed: $e\n$st');
      _initCompleter!.complete(); // allow play attempts anyway
    }
  }

  Future<void> _ensureReady() async {
    if (!_ready) await init();
  }

  Future<void> playBgm() async {
    await _ensureReady();
    if (_bgmPlaying) return;
    try {
      await _bgm.stop();
      await _bgm.setReleaseMode(ReleaseMode.loop);
      await _bgm.setVolume(musicVolume);
      await _bgm.play(AssetSource('audio/bgm.mp3'));
      _bgmPlaying = true;
    } catch (e, st) {
      _bgmPlaying = false;
      debugPrint('AudioService.playBgm failed: $e\n$st');
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgm.stop();
    } catch (_) {}
    _bgmPlaying = false;
  }

  Future<void> pauseBgm() async {
    try {
      await _bgm.pause();
    } catch (e, st) {
      debugPrint('AudioService.pauseBgm failed: $e\n$st');
    }
  }

  Future<void> resumeBgm() async {
    if (!_bgmPlaying) return;
    try {
      await _bgm.resume();
    } catch (e, st) {
      debugPrint('AudioService.resumeBgm failed: $e\n$st');
    }
  }

  Future<void> playLevelClear() async {
    await _ensureReady();
    try {
      await _bgm.stop();
      _bgmPlaying = false;
      await _sfx.stop();
      await _sfx.setVolume(soundVolume);
      await _sfx.play(AssetSource('audio/level_clear.mp3'));
    } catch (e, st) {
      debugPrint('AudioService.playLevelClear failed: $e\n$st');
    }
  }

  Future<void> resumeBgmAfterClear() async {
    _bgmPlaying = false;
    await playBgm();
  }

  Future<void> setMusicVolume(double v) async {
    musicVolume = v.clamp(0, 1);
    await _bgm.setVolume(musicVolume);
  }

  Future<void> setSoundVolume(double v) async {
    soundVolume = v.clamp(0, 1);
    await _sfx.setVolume(soundVolume);
  }

  Future<void> dispose() async {
    await _bgm.dispose();
    await _sfx.dispose();
  }
}
