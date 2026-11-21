# PipeLeap (Flutter)

Original side-scrolling platformer — Flutter + Flame, offline, Play Store–ready packaging.

## Run

```bash
cd mobile
flutter pub get
flutter run
```

Landscape controls: D-pad left/right, jump, fire, pipe enter. Gamepads supported.

## Features

- 10 levels with power-ups, enemies, checkpoints, pipes, spikes
- High scores, save/load, statistics, difficulty modes
- Juice: squash/stretch, particles, hit-stop, screen shake, level-clear banner
- Offline fonts and original geometric hero art

## Android release (Play Store)

### 1. Signing

A upload keystore is created via:

```bash
./tool/generate_keystore.sh
```

This writes (gitignored):

- `android/upload-keystore.jks`
- `android/key.properties`

**Back up both securely.** Losing them blocks updates on Play.

Template without secrets: `android/key.properties.example`

### 2. Build App Bundle

```bash
flutter pub get
dart run flutter_launcher_icons
flutter build appbundle --release
```

Output:

`build/app/outputs/bundle/release/app-release.aab`

Package ID: `com.pipeleap.mobile`

### 3. Privacy policy (required by Play)

Host the static page:

`privacy/index.html`

on GitHub Pages, Netlify, Cloudflare Pages, or any HTTPS static host. Put the URL in Play Console.

No game backend is required — saves stay on-device.

### 4. Store listing copy

See [`store/LISTING.md`](store/LISTING.md). Store art lives in `assets/store/`.

## Regenerate art / audio

```bash
python3 tool/generate_assets.py
```

## Version

`pubspec.yaml` → `version: 1.0.0+1` (`versionName`+`versionCode`). Bump before each Play upload.
