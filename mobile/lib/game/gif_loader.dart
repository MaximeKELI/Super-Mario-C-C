import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class GifFrameData {
  final ui.Image image;
  final double delaySeconds;

  const GifFrameData(this.image, this.delaySeconds);
}

/// Decodes an animated GIF asset into Flame-ready frames (same idea as C++ IMG_LoadGIFAnimation).
class GifLoader {
  static final Map<String, Future<List<GifFrameData>>> _cache = {};

  static Future<List<GifFrameData>> load(String assetPath) {
    return _cache.putIfAbsent(assetPath, () => _decode(assetPath));
  }

  static Future<List<GifFrameData>> _decode(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final animation = img.GifDecoder().decode(bytes) ?? img.decodeAnimation(bytes);
    if (animation == null || animation.frames.isEmpty) {
      throw StateError('Failed to decode GIF: $assetPath');
    }

    final frames = <GifFrameData>[];
    for (final frame in animation.frames) {
      final png = Uint8List.fromList(img.encodePng(frame));
      final image = await _pngToUiImage(png);
      final delayMs = frame.frameDuration <= 0 ? 100 : frame.frameDuration;
      frames.add(GifFrameData(image, delayMs / 1000.0));
    }
    return frames;
  }

  static Future<ui.Image> _pngToUiImage(Uint8List png) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(png, completer.complete);
    return completer.future;
  }
}
