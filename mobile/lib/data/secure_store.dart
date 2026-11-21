import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline integrity: Keystore-backed device key + HMAC seals + sanitization.
///
/// Play-Store safe (no root bans, no network attestation). Not DRM against a
/// fully patched APK — raises cost of prefs/backup/static-string attacks.
class SecureStore {
  SecureStore._();

  static const _secureKeyName = 'pl_ik_v3';
  static const _secureGenName = 'pl_gen_v3';
  static const _legacyPrefsKey = 'pl_ik';
  static const _appBind = 'com.pipeleap.mobile|PipeLeap|v3';
  static const _schema = 3;
  static const maxPayloadBytes = 48 * 1024;

  static const maxNameLen = 12;
  static const maxScore = 999999;
  static const maxLevel = 10;
  static const maxLives = 5;
  static const maxCoins = 99;
  static const maxStatInt = 1000000;
  static const maxPlayTime = 60 * 60 * 1000.0;

  static final RegExp _nameAllowed = RegExp(r"[A-Za-z0-9 _\-'.]");

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Uint8List? _deviceKey;
  static Uint8List? _signingKey;
  static Future<Uint8List>? _keyFuture;
  static bool _testMode = false;
  static int _testGen = 0;

  static void _log(String msg) {
    if (!kReleaseMode) debugPrint(msg);
  }

  /// Warm Keystore on startup (call from main).
  static Future<void> warmup() async {
    await deviceKey();
  }

  static Future<Uint8List> deviceKey() {
    return _keyFuture ??= _loadOrCreateKey();
  }

  static Future<Uint8List> _loadOrCreateKey() async {
    if (_deviceKey != null) return _deviceKey!;

    // 1) Android Keystore / iOS Keychain
    if (!_testMode) {
      try {
        final fromSecure = await _storage.read(key: _secureKeyName);
        if (fromSecure != null && fromSecure.isNotEmpty) {
          final bytes = base64Decode(fromSecure);
          if (bytes.length >= 32) {
            _deviceKey = Uint8List.fromList(bytes.take(32).toList());
            _signingKey = _deriveSigningKey(_deviceKey!);
            return _deviceKey!;
          }
        }
      } catch (e) {
        _log('SecureStore: secure storage read failed: $e');
      }
    }

    // 2) Migrate legacy SharedPreferences key → Keystore, then wipe prefs.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_legacyPrefsKey);
    if (legacy != null && legacy.isNotEmpty) {
      try {
        final bytes = base64Decode(legacy);
        if (bytes.length >= 32) {
          _deviceKey = Uint8List.fromList(bytes.take(32).toList());
          await _persistKey(_deviceKey!);
          await prefs.remove(_legacyPrefsKey);
          _signingKey = _deriveSigningKey(_deviceKey!);
          return _deviceKey!;
        }
      } catch (_) {}
      await prefs.remove(_legacyPrefsKey);
    }

    // 3) Fresh install
    final rnd = Random.secure();
    final key = Uint8List.fromList(List.generate(32, (_) => rnd.nextInt(256)));
    _deviceKey = key;
    await _persistKey(key);
    _signingKey = _deriveSigningKey(key);
    return key;
  }

  static Future<void> _persistKey(Uint8List key) async {
    if (_testMode) return;
    try {
      await _storage.write(key: _secureKeyName, value: base64Encode(key));
    } catch (e) {
      _log('SecureStore: secure storage write failed, prefs fallback: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_legacyPrefsKey, base64Encode(key));
    }
  }

  /// Bind HMAC material to package id so a raw key dump is not enough alone.
  static Uint8List _deriveSigningKey(Uint8List deviceKey) {
    final material = <int>[
      ...deviceKey,
      ...utf8.encode(_appBind),
      _schema,
    ];
    return Uint8List.fromList(sha256.convert(material).bytes);
  }

  static Future<Uint8List> _signingKeyBytes() async {
    await deviceKey();
    return _signingKey!;
  }

  @visibleForTesting
  static void debugSetDeviceKey(Uint8List key) {
    _testMode = true;
    _testGen = 0;
    _deviceKey = Uint8List.fromList(key);
    _signingKey = _deriveSigningKey(_deviceKey!);
    _keyFuture = Future.value(_deviceKey!);
  }

  @visibleForTesting
  static void debugResetKeyCache() {
    _deviceKey = null;
    _signingKey = null;
    _keyFuture = null;
    _testMode = false;
    _testGen = 0;
  }

  /// Keystore-backed generation watermark (not plain SharedPreferences).
  static Future<int> readGeneration() async {
    if (_testMode) return _testGen;
    try {
      final raw = await _storage.read(key: _secureGenName);
      return int.tryParse(raw ?? '0')?.clamp(0, 1 << 30) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> writeGeneration(int gen) async {
    final g = gen.clamp(0, 1 << 30);
    if (_testMode) {
      _testGen = g;
      return;
    }
    try {
      await _storage.write(key: _secureGenName, value: '$g');
    } catch (e) {
      _log('SecureStore.writeGeneration failed: $e');
    }
  }

  static Future<int> bumpGeneration() async {
    final next = (await readGeneration()) + 1;
    await writeGeneration(next);
    return next;
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
    return Hmac(sha256, key).convert(utf8.encode(body)).toString();
  }

  static Future<Map<String, dynamic>> seal(Map<String, dynamic> payload) async {
    final key = await _signingKeyBytes();
    return {
      'v': _schema,
      'payload': payload,
      'sig': _sign(payload, key),
    };
  }

  static Future<Map<String, dynamic>?> open(dynamic decoded) async {
    try {
      if (decoded is List) {
        _log('SecureStore: rejected raw list payload');
        return null;
      }
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);

      if (!map.containsKey('sig') || !map.containsKey('payload')) {
        _log('SecureStore: rejected unsealed payload');
        return null;
      }

      final payloadRaw = map['payload'];
      if (payloadRaw is! Map) return null;
      final payload = Map<String, dynamic>.from(payloadRaw);

      final encoded = utf8.encode(canonicalJson(payload));
      if (encoded.length > maxPayloadBytes) {
        _log('SecureStore: payload too large');
        return null;
      }

      final sig = map['sig'] as String? ?? '';
      final key = await _signingKeyBytes();
      final expected = _sign(payload, key);
      if (!_constantTimeEquals(sig, expected)) {
        _log('SecureStore: integrity check failed');
        return null;
      }
      return payload;
    } catch (e, st) {
      _log('SecureStore.open failed: $e\n$st');
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
