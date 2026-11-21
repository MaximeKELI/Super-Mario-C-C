import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Offline integrity helpers: HMAC seals + input/save sanitization.
///
/// This is not DRM — a determined attacker with a patched APK can bypass it —
/// but it stops casual SharedPreferences / backup edits from forging scores.
class SecureStore {
  SecureStore._();

  /// App pepper (rotated if we ever break sealed format).
  static const _pepper = 'PipeLeap.v1.integrity.2026!#';

  static const maxNameLen = 12;
  static const maxScore = 999999;
  static const maxLevel = 10;
  static const maxLives = 99;
  static const maxCoins = 99;
  static const maxStatInt = 1000000;
  static const maxPlayTime = 60 * 60 * 1000.0; // ~1000h seconds-cap for sanity

  static final RegExp _nameAllowed = RegExp(r"[A-Za-z0-9 _\-'.]");

  static String sanitizeName(String? raw, {String fallback = 'Player'}) {
    if (raw == null) return fallback;
    final buf = StringBuffer();
    for (final rune in raw.runes) {
      final ch = String.fromCharCode(rune);
      if (_nameAllowed.hasMatch(ch)) buf.write(ch);
      if (buf.length >= maxNameLen) break;
    }
    final cleaned = buf.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return fallback;
    return cleaned;
  }

  static int clampScore(num? v) => (v ?? 0).round().clamp(0, maxScore);

  static int clampLevel(num? v) => (v ?? 1).round().clamp(1, maxLevel);

  static int clampLives(num? v) => (v ?? 3).round().clamp(0, maxLives);

  static int clampCoins(num? v) => (v ?? 0).round().clamp(0, maxCoins);

  static int clampStatInt(num? v) => (v ?? 0).round().clamp(0, maxStatInt);

  static double clampPlayTime(num? v) =>
      (v ?? 0).toDouble().clamp(0.0, maxPlayTime);

  static double clampCoord(num? v, {double fallback = 100}) {
    final d = (v ?? fallback).toDouble();
    if (d.isNaN || d.isInfinite) return fallback;
    return d.clamp(-5000.0, 20000.0);
  }

  /// Canonical JSON (sorted keys) so HMAC is stable.
  static String canonicalJson(Object? value) {
    return jsonEncode(_canonicalize(value));
  }

  static dynamic _canonicalize(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((k) => '$k').toList()..sort();
      return {
        for (final k in keys) k: _canonicalize(value[k]),
      };
    }
    if (value is List) {
      return value.map(_canonicalize).toList();
    }
    if (value is num) {
      if (value.isNaN || value.isInfinite) return 0;
      return value;
    }
    return value;
  }

  static String signMap(Map<String, dynamic> payload) {
    final body = canonicalJson(payload);
    final hmac = Hmac(sha256, utf8.encode(_pepper));
    return hmac.convert(utf8.encode(body)).toString();
  }

  /// Wrap payload with version + signature.
  static Map<String, dynamic> seal(Map<String, dynamic> payload) {
    return {
      'v': 1,
      'payload': payload,
      'sig': signMap(payload),
    };
  }

  /// Returns payload if signature OK; otherwise null.
  static Map<String, dynamic>? open(dynamic decoded) {
    try {
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);

      // Legacy unsealed payloads (pre-integrity) — accept once, re-seal on save.
      if (!map.containsKey('sig') && !map.containsKey('payload')) {
        return map;
      }

      final payloadRaw = map['payload'];
      if (payloadRaw is! Map) return null;
      final payload = Map<String, dynamic>.from(payloadRaw);
      final sig = map['sig'] as String? ?? '';
      final expected = signMap(payload);
      if (!_constantTimeEquals(sig, expected)) {
        debugPrint('SecureStore: integrity check failed — discarding data');
        return null;
      }
      return payload;
    } catch (e, st) {
      debugPrint('SecureStore.open failed: $e\n$st');
      return null;
    }
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
