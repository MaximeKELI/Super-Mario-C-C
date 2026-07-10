import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._();
  static final instance = AudioService._();

  final _bgm = AudioPlayer();
  final _sfx = AudioPlayer();
  double musicVolume = 0.7;
  double soundVolume = 0.9;
  bool _bgmPlaying = false;

  Future<void> init() async {
    await _bgm.setReleaseMode(ReleaseMode.loop);
    await _bgm.setVolume(musicVolume);
    await _sfx.setVolume(soundVolume);
  }

  Future<void> playBgm() async {
    if (_bgmPlaying) return;
    try {
      await _bgm.play(AssetSource('audio/bgm.mp3'));
      _bgmPlaying = true;
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    await _bgm.stop();
    _bgmPlaying = false;
  }

  Future<void> playLevelClear() async {
    try {
      await _bgm.stop();
      _bgmPlaying = false;
      await _sfx.play(AssetSource('audio/level_clear.mp3'));
    } catch (_) {}
  }

  Future<void> resumeBgmAfterClear() async {
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
