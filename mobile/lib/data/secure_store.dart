import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline integrity: device-bound HMAC + input sanitization.
///
/// Not DRM against a patched APK — stops prefs/backup forgeries and
/// static-pepper cracks that worked on v1.
class SecureStore {
  SecureStore._();

  static const _keyPrefs = 'pl_ik'; // device integrity key (base64)
  static const _schema = 2;
  static const maxPayloadBytes = 48 * 1024;

  static const maxNameLen = 12;
  static const maxScore = 999999;
  static const maxLevel = 10;
  static const maxLives = 5; // hard cap matches easiest difficulty start
  static const maxCoins = 99;
  static const maxStatInt = 1000000;
  static const maxPlayTime = 60 * 60 * 1000.0;

  static final RegExp _nameAllowed = RegExp(r"[A-Za-z0-9 _\-'.]");

  static Uint8List? _deviceKey;
  static Future<Uint8List>? _keyFuture;

  /// Load or create a per-install HMAC key (not in source / APK strings).
  static Future<Uint8List> deviceKey() {
    return _keyFuture ??= _loadOrCreateKey();
  }

  static Future<Uint8List> _loadOrCreateKey() async {
    if (_deviceKey != null) return _deviceKey!;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyPrefs);
    if (existing != null && existing.isNotEmpty) {
      try {
        final bytes = base64Decode(existing);
        if (bytes.length >= 32) {
          _deviceKey = Uint8List.fromList(bytes.take(32).toList());
          return _deviceKey!;
        }
      } catch (_) {}
    }
    final rnd = Random.secure();
    final key = Uint8List.fromList(List.generate(32, (_) => rnd.nextInt(256)));
    await prefs.setString(_keyPrefs, base64Encode(key));
    _deviceKey = key;
    return key;
  }

  /// Test-only: inject key (resets cached future).
  @visibleForTesting
  static void debugSetDeviceKey(Uint8List key) {
    _deviceKey = Uint8List.fromList(key);
    _keyFuture = Future.value(_deviceKey!);
  }

  @visibleForTesting
  static void debugResetKeyCache() {
    _deviceKey = null;
    _keyFuture = null;
  }

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

  static String canonicalJson(Object? value) => jsonEncode(_canonicalize(value));

  static dynamic _canonicalize(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((k) => '$k').toList()..sort();
      return {for (final k in keys) k: _canonicalize(value[k])};
    }
    if (value is List) return value.map(_canonicalize).toList();
    if (value is num) {
      if (value.isNaN || value.isInfinite) return 0;
      return value;
    }
    return value;
  }

  static String _sign(Map<String, dynamic> payload, Uint8List key) {
    final body = canonicalJson(payload);
    final hmac = Hmac(sha256, key);
    return hmac.convert(utf8.encode(body)).toString();
  }

  static Future<Map<String, dynamic>> seal(Map<String, dynamic> payload) async {
    final key = await deviceKey();
    return {
      'v': _schema,
      'payload': payload,
      'sig': _sign(payload, key),
    };
  }

  /// Returns payload only if sealed with **this device** key.
  /// Rejects: unsealed maps, raw lists, foreign/static-pepper forgeries.
  static Future<Map<String, dynamic>?> open(dynamic decoded) async {
    try {
      if (decoded is List) {
        debugPrint('SecureStore: rejected raw list payload');
        return null;
      }
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);

      // Hard reject cleartext / legacy unsealed saves (former critical hole).
      if (!map.containsKey('sig') || !map.containsKey('payload')) {
        debugPrint('SecureStore: rejected unsealed payload');
        return null;
      }

      final payloadRaw = map['payload'];
      if (payloadRaw is! Map) return null;
      final payload = Map<String, dynamic>.from(payloadRaw);

      final encoded = utf8.encode(canonicalJson(payload));
      if (encoded.length > maxPayloadBytes) {
        debugPrint('SecureStore: payload too large');
        return null;
      }

      final sig = map['sig'] as String? ?? '';
      final key = await deviceKey();
      final expected = _sign(payload, key);
      if (!_constantTimeEquals(sig, expected)) {
        debugPrint('SecureStore: integrity check failed');
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
