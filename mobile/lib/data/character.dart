import 'package:shared_preferences/shared_preferences.dart';

import 'secure_store.dart';

/// Selectable playable skins.
enum PlayableCharacter {
  mario,
  pip;

  String get displayName => switch (this) {
        // Store-safe label (no Nintendo trademark in UI / listings).
        PlayableCharacter.mario => 'Retro',
        PlayableCharacter.pip => 'Pip',
      };

  String get tagline => switch (this) {
        PlayableCharacter.mario => 'Classic runner',
        PlayableCharacter.pip => 'PipeLeap original',
      };

  String get framesDir => switch (this) {
        PlayableCharacter.mario => 'assets/images/mario_frames',
        PlayableCharacter.pip => 'assets/images/hero_frames',
      };

  String get previewAsset => switch (this) {
        PlayableCharacter.mario => 'assets/images/Mario_clean.webp',
        PlayableCharacter.pip => 'assets/images/hero.png',
      };

  String get fallbackAsset => switch (this) {
        PlayableCharacter.mario => 'assets/images/Mario.gif',
        PlayableCharacter.pip => 'assets/images/hero.png',
      };

  static PlayableCharacter fromId(String? id) {
    return PlayableCharacter.values.firstWhere(
      (c) => c.name == id,
      orElse: () => PlayableCharacter.pip,
    );
  }
}

class CharacterPrefs {
  static const _key = 'pipeleap_character';

  Future<PlayableCharacter> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PlayableCharacter.fromId(prefs.getString(_key));
  }

  Future<void> save(PlayableCharacter character) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, character.name);
  }
}

class PlayerNamePrefs {
  static const _key = 'pipeleap_player_name';

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    final name = SecureStore.sanitizeName(raw, fallback: '');
    if (name.isEmpty) return null;
    return name;
  }

  Future<void> save(String name) async {
    final cleaned = SecureStore.sanitizeName(name, fallback: '');
    if (cleaned.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, cleaned);
  }
}
