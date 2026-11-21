import 'package:shared_preferences/shared_preferences.dart';

/// Selectable playable skins.
enum PlayableCharacter {
  mario,
  pip;

  String get displayName => switch (this) {
        PlayableCharacter.mario => 'Mario',
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
