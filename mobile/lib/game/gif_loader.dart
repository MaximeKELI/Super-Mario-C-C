import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../data/character.dart';

class GifFrameData {
  final ui.Image image;
  final double delaySeconds;

  const GifFrameData(this.image, this.delaySeconds);
}

/// Loads character animations from pre-baked PNGs (fast) with image fallback.
class GifLoader {
  static final Map<String, Future<List<GifFrameData>>> _cache = {};
  static final Map<PlayableCharacter, List<GifFrameData>> framesByCharacter = {};

  static const _frameCount = 12;

  static List<GifFrameData>? framesFor(PlayableCharacter character) =>
      framesByCharacter[character];

  static Future<List<GifFrameData>> load(
    String assetPath, {
    required PlayableCharacter character,
    int targetWidth = 96,
  }) {
    final key = '${character.name}:$assetPath@$targetWidth';
    return _cache.putIfAbsent(
      key,
      () => _decode(assetPath, character, targetWidth),
    );
  }

  /// Preload both skins during splash.
  static Future<void> preloadAll() async {
    await Future.wait([
      for (final c in PlayableCharacter.values) _preloadOne(c),
    ]);
  }

  static Future<void> _preloadOne(PlayableCharacter character) async {
    framesByCharacter[character] = await _loadPngFrames(character.framesDir);
  }

  static Future<List<GifFrameData>> _loadPngFrames(String framesDir) async {
    final delaysRaw = await rootBundle.loadString('$framesDir/delays.txt');
    final delays = delaysRaw
        .split(',')
        .map((e) => int.tryParse(e.trim()) ?? 80)
        .toList();

    final frames = <GifFrameData>[];
    for (var i = 0; i < _frameCount; i++) {
      final data = await rootBundle.load(
        '$framesDir/frame_${i.toString().padLeft(2, '0')}.png',
      );
      final image = await _decodePng(data.buffer.asUint8List());
      final ms = i < delays.length ? delays[i] : 80;
      frames.add(GifFrameData(image, (ms <= 0 ? 80 : ms) / 1000.0));
    }
    return frames;
  }

  static Future<List<GifFrameData>> _decode(
    String assetPath,
    PlayableCharacter character,
    int targetWidth,
  ) async {
    try {
      return await _loadPngFrames(character.framesDir);
    } catch (_) {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: targetWidth);
      final frames = <GifFrameData>[];
      for (var i = 0; i < codec.frameCount; i++) {
        final info = await codec.getNextFrame();
        final ms = info.duration.inMilliseconds;
        frames.add(GifFrameData(info.image, (ms <= 0 ? 80 : ms) / 1000.0));
      }
      return frames;
    }
  }

  static Future<ui.Image> _decodePng(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final info = await codec.getNextFrame();
    return info.image;
  }
}
