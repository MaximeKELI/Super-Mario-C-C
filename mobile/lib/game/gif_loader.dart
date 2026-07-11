import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class GifFrameData {
  final ui.Image image;
  final double delaySeconds;

  const GifFrameData(this.image, this.delaySeconds);
}

/// Loads Mario animation from pre-baked small PNGs (fast) with GIF fallback.
class GifLoader {
  static final Map<String, Future<List<GifFrameData>>> _cache = {};
  static List<GifFrameData>? marioFrames;

  static const _frameCount = 12;
  static const _framesDir = 'assets/images/mario_frames';

  static Future<List<GifFrameData>> load(
    String assetPath, {
    int targetWidth = 96,
  }) {
    final key = '$assetPath@$targetWidth';
    return _cache.putIfAbsent(key, () => _decode(assetPath, targetWidth));
  }

  /// Call during splash so the first level starts instantly.
  static Future<void> preloadMario() async {
    marioFrames = await _loadPngFrames();
  }

  static Future<List<GifFrameData>> _loadPngFrames() async {
    final delaysRaw = await rootBundle.loadString('$_framesDir/delays.txt');
    final delays = delaysRaw
        .split(',')
        .map((e) => int.tryParse(e.trim()) ?? 80)
        .toList();

    final frames = <GifFrameData>[];
    for (var i = 0; i < _frameCount; i++) {
      final data = await rootBundle.load('$_framesDir/frame_${i.toString().padLeft(2, '0')}.png');
      final image = await _decodePng(data.buffer.asUint8List());
      final ms = i < delays.length ? delays[i] : 80;
      frames.add(GifFrameData(image, (ms <= 0 ? 80 : ms) / 1000.0));
    }
    return frames;
  }

  static Future<List<GifFrameData>> _decode(String assetPath, int targetWidth) async {
    try {
      return await _loadPngFrames();
    } catch (_) {
      // Fallback: native GIF codec scaled down
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
