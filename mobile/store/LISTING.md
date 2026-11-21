# PipeLeap — Google Play listing pack

## App identity

| Field | Value |
|-------|-------|
| Title | PipeLeap |
| Package name | `com.pipeleap.mobile` |
| Default language | English (US) |
| Category | Games → Arcade / Platformer |
| Free | Yes |

## Short description (≤80 chars)

```
Leap through 10 colorful worlds in this original offline platformer.
```

## Full description

```
PipeLeap is an original side-scrolling platformer built for phones and tablets.

Race across ten handcrafted levels packed with moving platforms, pipes, power-ups, checkpoints, and bosses. Collect coins, chase high scores, and tune difficulty from Easy to Hard.

Features
• 10 unique levels with progressive challenge
• Power-ups, enemies, pipes, spikes, and checkpoints
• Save / load, high scores, and play statistics
• Virtual controls + gamepad support
• Landscape immersive play
• 100% offline — no ads, no account, no tracking

Jump in, find your rhythm, and PipeLeap to the finish.
```

## Graphics (in `assets/store/`)

| Asset | File | Size |
|-------|------|------|
| High-res icon | `icon_512.png` | 512×512 |
| Source icon | `icon_1024.png` | 1024×1024 |
| Feature graphic | `feature_graphic.png` | 1024×500 |

Still needed from a real device/emulator:

- Phone screenshots (min 2): landscape gameplay + menu
- Optional 7" / 10" tablet screenshots

## Data safety (Play Console answers)

- Does the app collect / share user data? **No**
- Is all user data encrypted in transit? **N/A** (no network data)
- Can users request data deletion? **N/A** (local only; uninstall clears)
- Collected data types: **None**
- Security practices: data is processed ephemerally / not collected

## Privacy policy URL

Host [`privacy/index.html`](../privacy/index.html) on any static host, then paste the public HTTPS URL into Play Console.

Examples:

```bash
# GitHub Pages (from repo root / mobile)
# push privacy/ to a pages branch or /docs site
```

## Content rating

Expect a low PEGI / ESRB-style rating for mild cartoon violence (jumping on enemies). Complete the IARC questionnaire in Play Console honestly.

## Target audience

- Age groups: 3+ / Everyone (confirm via questionnaire)
- Not primarily “designed for children” storefront program unless you opt in

## Release checklist

1. [ ] Google Play developer account created
2. [ ] Privacy policy URL live (HTTPS)
3. [ ] `flutter build appbundle --release` → upload `app-release.aab`
4. [ ] Store listing text + icon + feature graphic uploaded
5. [ ] ≥2 phone screenshots uploaded
6. [ ] Data safety form completed (no data collected)
7. [ ] Content rating questionnaire completed
8. [ ] Countries / pricing set
9. [ ] Internal / closed testing track before production
