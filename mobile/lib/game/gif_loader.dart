import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class GifFrameData {
  final ui.Image image;
  final double delaySeconds;

  const GifFrameData(this.image, this.delaySeconds);
}

/// Fast GIF decode via Flutter's native codec (scaled down for gameplay).
class GifLoader {
  static final Map<String, Future<List<GifFrameData>>> _cache = {};
  static List<GifFrameData>? marioFrames;

  static Future<List<GifFrameData>> load(
    String assetPath, {
    int targetWidth = 96,
  }) {
    final key = '$assetPath@$targetWidth';
    return _cache.putIfAbsent(key, () => _decode(assetPath, targetWidth));
  }

  /// Call during splash so the first level starts instantly.
  static Future<void> preloadMario() async {
    marioFrames = await load('assets/images/Mario.gif', targetWidth: 96);
  }

  static Future<List<GifFrameData>> _decode(String assetPath, int targetWidth) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
    );

    final frames = <GifFrameData>[];
    for (var i = 0; i < codec.frameCount; i++) {
      final info = await codec.getNextFrame();
      final ms = info.duration.inMilliseconds;
      frames.add(GifFrameData(
        info.image,
        (ms <= 0 ? 80 : ms) / 1000.0,
      ));
    }
    return frames;
  }
}
