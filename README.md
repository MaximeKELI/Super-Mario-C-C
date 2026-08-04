# 🎮 SUPER MARIO GAME - Documentation Complète

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![C++](https://img.shields.io/badge/C++-17-orange.svg)
![SDL2](https://img.shields.io/badge/SDL2-2.0-yellow.svg)

**Un jeu de plateforme 2D inspiré de Super Mario Bros, développé en C++ avec SDL2**

[🎯 Fonctionnalités](#-fonctionnalités) • [📦 Installation](#-installation) • [🎮 Contrôles](#-contrôles) • [📊 Architecture](#-architecture) • [🗄️ Base de données](#️-base-de-données)

</div>

---

## 📑 Table des Matières

1. [🎯 Vue d'ensemble](#-vue-densemble)
2. [✨ Fonctionnalités](#-fonctionnalités)
3. [📦 Installation](#-installation)
4. [🎮 Utilisation](#-utilisation)
5. [🎨 Ressources Multimédia](#-ressources-multimédia)
6. [🏗️ Architecture du Projet](#️-architecture-du-projet)
7. [🗄️ Modèles de Données (MCD/MLD)](#️-modèles-de-données-mcdmld)
8. [📊 Tableaux Récapitulatifs](#-tableaux-récapitulatifs)
9. [🔧 Configuration](#-configuration)
10. [🧪 Tests](#-tests)
11. [📝 Structure du Code](#-structure-du-code)

---

## 🎯 Vue d'ensemble

Super Mario Game est un jeu de plateforme 2D développé en C++ utilisant la bibliothèque SDL2. Le jeu propose :

- ✨ **10+ niveaux** uniques avec des défis progressifs
- 🎵 **Système audio complet** avec musique de fond et effets sonores
- 📊 **Système de scores** avec classement des meilleurs scores
- 💾 **Sauvegarde/Chargement** de partie
- 📈 **Statistiques détaillées** de jeu
- 🎨 **Graphismes animés** (GIF)
- 🗺️ **Mini-map** pour l'orientation
- 🎚️ **3 niveaux de difficulté** (Facile, Normal, Difficile)

---

## ✨ Fonctionnalités

### 🎮 Fonctionnalités Principales

| Fonctionnalité | Description | Statut |
|----------------|-------------|--------|
| **Animation GIF** | Personnage Mario animé avec GIF | ✅ |
| **10+ Niveaux** | Niveaux progressifs avec layouts uniques | ✅ |
| **Système de Score** | Points basés sur les actions | ✅ |
| **High Scores** | Top 10 des meilleurs scores sauvegardés | ✅ |
| **Statistiques** | Temps, ennemis tués, distance, etc. | ✅ |
| **Sauvegarde** | Sauvegarde automatique et manuelle | ✅ |
| **Checkpoints** | Points de sauvegarde dans les niveaux | ✅ |
| **Mini-map** | Carte minimale avec position | ✅ |
| **Difficulté** | 3 niveaux (Facile, Normal, Difficile) | ✅ |
| **Musique** | Musique de fond et musique de fin de niveau | ✅ |

### 🎁 Power-ups Disponibles

| Power-up | Effet | Durée | Icône |
|----------|-------|-------|-------|
| 🍄 **Mushroom** | Agrandit Mario | Permanent | Rouge |
| 🔥 **Fire Flower** | Permet de lancer des boules de feu | Permanent | Rouge/Jaune |
| 🪶 **Feather** | Permet de voler | 8 secondes | Blanc |
| ⭐ **Star** | Invincibilité | 12 secondes | Jaune |
| 💚 **1-Up** | Vie supplémentaire | Instantané | Vert |
| ☄️ **Comet** | Vitesse x2 | 10 secondes | Bleu |

### 👾 Types d'Ennemis

| Ennemi | Type | PV | Comportement |
|--------|------|----|--------------|
| 🐢 **Goomba** | Standard | 1 | Marche au sol |
| 🐢 **Koopa** | Standard | 1 | Marche et saute |
| 🦇 **Flying** | Volant | 1 | Vol en hauteur |
| 👹 **Boss** | Boss | 3 | Plus grand, plus résistant |

### 🏗️ Éléments du Niveau

| Élément | Description | Type |
|---------|-------------|------|
| 📦 **Plateforme** | Sol sur lequel marcher | Statique/Mobile/Destructible |
| 🧱 **Bloc de Brique** | Bloc destructible | Destructible |
| ❓ **Bloc Question** | Contient des power-ups | Interactif |
| ⚠️ **Spike** | Obstacle mortel | Dangereux |
| 🚩 **Checkpoint** | Point de sauvegarde | Interactif |
| 🌫️ **Nuage** | Décoration avec parallaxe | Décoratif |
| 🚪 **Tuyau** | Téléportation | Interactif |

---

## 📦 Installation

### Prérequis

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install build-essential
sudo apt-get install libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-mixer-dev

# Fedora/RHEL
sudo dnf install gcc-c++ SDL2-devel SDL2_image-devel SDL2_ttf-devel SDL2_mixer-devel

# Arch Linux
sudo pacman -S base-devel sdl2 sdl2_image sdl2_ttf sdl2_mixer
```

### Compilation

```bash
# Cloner ou télécharger le projet
cd jeu_super_mario

# Compiler
make

# Exécuter
./super_mario
```

### Nettoyage

```bash
make clean  # Supprime les fichiers compilés
```

---

## 🎮 Utilisation

### 🎯 Contrôles

| Touche | Action |
|--------|--------|
| **← →** ou **A D** | Déplacer gauche/droite |
| **↑** ou **Espace** ou **W** | Sauter |
| **X** | Lancer des boules de feu (si power-up feu) |
| **P** ou **Échap** | Pause/Menu pause |
| **Entrée** | Confirmer/Menu |
| **H** | High Scores (dans le menu) |
| **S** | Statistiques (dans le menu) |
| **L** | Charger partie (dans le menu) |

### 📋 Menu Principal

```
┌─────────────────────────────────────┐
│         SUPER MARIO                 │
├─────────────────────────────────────┤
│  ENTREE - Nouvelle partie           │
│  H - High Scores                    │
│  S - Statistiques                   │
│  L - Charger partie                 │
└─────────────────────────────────────┘
```

### ⏸️ Menu Pause

```
┌─────────────────────────────────────┐
│            PAUSE                    │
├─────────────────────────────────────┤
│  > Reprendre                        │
│    Options                          │
│    Sauvegarder                      │
│    Menu Principal                   │
└─────────────────────────────────────┘
```

---

## 🎨 Ressources Multimédia

### 🎬 Animations (GIF)

| Fichier | Taille | Description | Utilisation |
|---------|--------|-------------|-------------|
| `src/Mario.gif` | ~905 lignes | Animation du personnage Mario | Personnage principal animé |

**Caractéristiques :**
- ✅ Animation fluide multi-frames
- ✅ Support de la direction (gauche/droite)
- ✅ Gestion des délais entre frames
- ✅ Chargement automatique au démarrage

### 🎵 Fichiers Audio (MP3)

| Fichier | Taille | Format | Description | Utilisation |
|---------|--------|--------|-------------|-------------|
| `src/06. Ragtime in the Skies.mp3` | **2.9 MB** | MP3 | Musique de fond principale - Style ragtime joyeux | 🔁 En boucle pendant le jeu |
| `src/20. Level Clear!.mp3` | **471 KB** | MP3 | Fanfare de victoire - Musique de fin de niveau | ▶️ Une fois par niveau complété |

**🎵 Caractéristiques audio :**

**Musique de Fond (06. Ragtime in the Skies.mp3) :**
- 🎼 **Style** : Ragtime/Jazz
- ⏱️ **Durée** : Variable (boucle infinie)
- 🔊 **Volume** : 128 (réglable 0-128)
- 🔄 **Mode** : Boucle infinie (`Mix_PlayMusic(music, -1)`)
- 🎚️ **Format** : MP3 stéréo

**Musique Level Clear (20. Level Clear!.mp3) :**
- 🎺 **Style** : Fanfare de victoire
- ⏱️ **Durée** : ~5-10 secondes
- 🔊 **Volume** : 128 (réglable 0-128)
- 🔄 **Mode** : Lecture unique (`Mix_PlayMusic(music, 0)`)
- 🎚️ **Format** : MP3 stéréo

**📊 Système Audio :**
```
┌─────────────────────────────────────────────┐
│          SYSTÈME AUDIO SDL2_MIXER          │
├─────────────────────────────────────────────┤
│  Fréquence: 44100 Hz                        │
│  Format: MIX_DEFAULT_FORMAT (16-bit)        │
│  Canaux: 2 (Stéréo)                         │
│  Buffer: 2048 bytes                         │
│                                             │
│  Musique de fond: En boucle                │
│  Musique Level Clear: Lecture unique       │
│  Transition: Automatique                    │
└─────────────────────────────────────────────┘
```

**🔧 Fonctionnalités :**
- 🔊 **Volume réglable** (0-128) - Via options
- 🔄 **Boucle automatique** - Pour musique de fond
- ⏹️ **Transition automatique** - Entre musiques
- 🎚️ **Mixage SDL2_mixer** - Gestion audio avancée
- 🎵 **Chargement dynamique** - Au démarrage du jeu

### 📊 Schéma du Système Audio

```
┌─────────────────────────────────────────────────────┐
│                 SYSTÈME AUDIO                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Démarrage                                          │
│    │                                                │
│    ├─→ Charger "06. Ragtime in the Skies.mp3"      │
│    │     │                                          │
│    │     └─→ Jouer en boucle (-1)                  │
│    │                                                │
│  Niveau complété                                    │
│    │                                                │
│    ├─→ Arrêter musique de fond                     │
│    │     │                                          │
│    │     ├─→ Jouer "20. Level Clear!.mp3" (0)      │
│    │     │     │                                    │
│    │     │     └─→ Attendre fin                    │
│    │     │           │                              │
│    │     │           └─→ Reprendre musique fond    │
│    │     │                 │                        │
│    │     │                 └─→ Boucle continue     │
│    │                                                │
│  Game Over / Menu                                   │
│    └─→ Musique de fond continue                    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🏗️ Architecture du Projet

### 📁 Structure des Fichiers

```
jeu_super_mario/
│
├── 📁 src/                          # Code source
│   ├── 🎮 Game.cpp/h               # Classe principale du jeu
│   ├── 👤 Player.cpp/h             # Personnage joueur
│   ├── 🏗️ Platform.cpp/h           # Plateformes
│   ├── 👾 Enemy.cpp/h              # Ennemis
│   ├── 🪙 Coin.cpp/h               # Pièces
│   ├── 🎁 PowerUp.cpp/h            # Power-ups
│   ├── 🧱 Block.cpp/h              # Blocs
│   ├── 🔥 Fireball.cpp/h           # Boules de feu
│   ├── ⚠️ Spike.cpp/h              # Piques
│   ├── 🌫️ Cloud.cpp/h              # Nuages
│   ├── 🚩 Checkpoint.cpp/h         # Checkpoints
│   ├── 🚪 Pipe.cpp/h               # Tuyaux
│   ├── ✨ Particle.h               # Particules
│   ├── 🎬 Mario.gif                # Animation du personnage
│   ├── 🎵 06. Ragtime in the Skies.mp3
│   └── 🎵 20. Level Clear!.mp3
│
├── 📁 obj/                          # Fichiers objets compilés
│
├── 📁 tests/                        # Tests unitaires
│   ├── test_framework.h
│   ├── test_game_structures.cpp
│   ├── test_player.cpp
│   └── Makefile
│
├── 📄 Makefile                      # Fichier de compilation
├── 📄 README.md                     # Cette documentation
└── 🎮 super_mario                   # Exécutable
```

### 🔄 Diagramme de Flux Principal

```
┌──────────────┐
│   DÉMARRAGE  │
└──────┬───────┘
       │
       ├─→ Initialiser SDL2
       ├─→ Initialiser SDL_image
       ├─→ Initialiser SDL_ttf
       ├─→ Initialiser SDL_mixer
       ├─→ Charger musique
       ├─→ Charger police
       ├─→ Créer fenêtre
       └─→ Charger niveau 1
            │
            ▼
┌───────────────────────┐
│   BOUCLE PRINCIPALE   │
│  ───────────────────  │
│                       │
│  ProcessInput()       │◄─────┐
│       │               │      │
│       ▼               │      │
│  Update(deltaTime)    │      │
│       │               │      │
│       ▼               │      │
│  Render()             │      │
│       │               │      │
│       ▼               │      │
│  SDL_Delay(16ms)      │      │
│       │               │      │
│       └───────────────┴──────┘
│                       │
│  État: MENU           │
│  État: PLAYING        │
│  État: PAUSED         │
│  État: GAME_OVER      │
│  État: LEVEL_COMPLETE │
│  État: HIGH_SCORES    │
│  État: STATISTICS     │
│                       │
└───────────────────────┘
```

---

## 🗄️ Modèles de Données (MCD/MLD)

### 📊 Modèle Conceptuel de Données (MCD)

```
┌─────────────────────────────────────────────────────────────┐
│                    MODÈLE CONCEPTUEL                        │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐
│    GAME      │         │    PLAYER    │
│──────────────│         │──────────────│
│ - score      │◄─────── │ - x, y       │
│ - lives      │ 1       │ - velocity   │
│ - level      │         │ - powerUps   │
│ - difficulty │         │ - state      │
└──────────────┘         └──────────────┘
      │                          │
      │                          │
      ├──────────────────────────┤
      │                          │
      ▼                          ▼
┌──────────────┐         ┌──────────────┐
│  HIGH_SCORE  │         │   ENTITIES   │
│──────────────│         │──────────────│
│ - name       │         │ - Platform   │
│ - score      │         │ - Enemy      │
│ - level      │         │ - Coin       │
│ - difficulty │         │ - PowerUp    │
└──────────────┘         │ - Block      │
                         │ - Spike      │
      │                  │ - Checkpoint │
      │                  │ - Pipe       │
      │                  └──────────────┘
      │
      ▼
┌──────────────┐
│ GAME_STATS   │
│──────────────│
│ - playTime   │
│ - enemiesKill│
│ - powerUps   │
│ - distance   │
│ - coins      │
│ - levelsDone │
└──────────────┘

      │
      ▼
┌──────────────┐
│  SAVE_DATA   │
│──────────────│
│ - level      │
│ - score      │
│ - lives      │
│ - checkpoint │
│ - stats      │
└──────────────┘
```

### 📋 Modèle Logique de Données (MLD)

#### Table: HIGH_SCORES

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `name` | VARCHAR(100) | NOT NULL | Nom du joueur |
| `score` | INTEGER | NOT NULL | Score obtenu |
| `level` | INTEGER | NOT NULL | Niveau atteint |
| `difficulty` | ENUM | NOT NULL | Difficulté (EASY, NORMAL, HARD) |

**Clé primaire :** (name, score, level, difficulty)  
**Index :** score (DESC)  
**Limite :** 10 enregistrements maximum

#### Table: GAME_STATS

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `totalPlayTime` | FLOAT | DEFAULT 0.0 | Temps total de jeu (secondes) |
| `enemiesKilled` | INTEGER | DEFAULT 0 | Nombre d'ennemis éliminés |
| `powerUpsCollected` | INTEGER | DEFAULT 0 | Power-ups collectés |
| `distanceTraveled` | FLOAT | DEFAULT 0.0 | Distance parcourue (pixels) |
| `totalCoinsCollected` | INTEGER | DEFAULT 0 | Pièces collectées |
| `levelsCompleted` | INTEGER | DEFAULT 0 | Niveaux complétés |

#### Table: SAVE_DATA

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `currentLevel` | INTEGER | DEFAULT 1 | Niveau actuel |
| `score` | INTEGER | DEFAULT 0 | Score actuel |
| `lives` | INTEGER | DEFAULT 3 | Vies restantes |
| `coinsCollected` | INTEGER | DEFAULT 0 | Pièces collectées |
| `checkpointX` | FLOAT | DEFAULT 100.0 | Position X du checkpoint |
| `checkpointY` | FLOAT | DEFAULT 100.0 | Position Y du checkpoint |
| `hasCheckpoint` | BOOLEAN | DEFAULT FALSE | Checkpoint activé |
| `difficulty` | ENUM | DEFAULT NORMAL | Difficulté actuelle |
| `stats` | GAME_STATS | - | Statistiques embarquées |

**Format de stockage :** Fichier binaire (`savegame.dat`)

---

## 📊 Tableaux Récapitulatifs

### 📈 Tableau des Classes Principales

| Classe | Responsabilité | Méthodes Principales | Dépendances |
|--------|----------------|----------------------|-------------|
| **Game** | Orchestration du jeu | `Run()`, `Update()`, `Render()`, `ProcessInput()` | Player, Enemy, Platform, etc. |
| **Player** | Contrôle du joueur | `Update()`, `HandleInput()`, `Collect*()`, `Shoot()` | SDL2, GIF animation |
| **Platform** | Plateformes | `Update()`, `Render()`, `Hit()` | SDL2 |
| **Enemy** | Ennemis | `Update()`, `Render()`, `Kill()` | SDL2 |
| **PowerUp** | Power-ups | `Update()`, `Render()`, `Collect()` | SDL2 |
| **Coin** | Pièces | `Update()`, `Render()`, `Collect()` | SDL2 |
| **Block** | Blocs | `Render()`, `Hit()` | SDL2 |
| **Fireball** | Projectiles | `Update()`, `Render()`, `Kill()` | SDL2 |
| **Spike** | Obstacles | `Render()` | SDL2 |
| **Checkpoint** | Points de sauvegarde | `Render()`, `Activate()` | SDL2 |
| **Pipe** | Téléportation | `Render()`, `Teleport()` | SDL2 |
| **Cloud** | Décoration | `Update()`, `Render()` | SDL2 |

### 🎯 Tableau des États du Jeu

| État | Description | Transitions Possibles |
|------|-------------|----------------------|
| **MENU** | Menu principal | → PLAYING (Entrée) |
| | | → HIGH_SCORES (H) |
| | | → STATISTICS (S) |
| **PLAYING** | En jeu | → PAUSED (P/Échap) |
| | | → GAME_OVER (mort) |
| | | → LEVEL_COMPLETE (fin niveau) |
| **PAUSED** | Pause | → PLAYING (reprendre) |
| | | → MENU (menu principal) |
| **GAME_OVER** | Fin de partie | → MENU (Entrée) |
| | | → ENTER_NAME (si high score) |
| **LEVEL_COMPLETE** | Niveau complété | → PLAYING (niveau suivant) |
| **HIGH_SCORES** | Classement | → MENU (Échap) |
| **STATISTICS** | Statistiques | → MENU (Échap) |
| **ENTER_NAME** | Saisie nom | → MENU (Entrée) |

### 📊 Tableau des Constantes du Jeu

| Constante | Valeur | Description |
|-----------|--------|-------------|
| **GRAVITY** | 800.0f | Gravité appliquée au joueur |
| **JUMP_FORCE** | -400.0f | Force de saut |
| **MOVE_SPEED** | 200.0f | Vitesse de déplacement |
| **MAX_FALL_SPEED** | 500.0f | Vitesse de chute max |
| **SHOOT_COOLDOWN** | 0.5f | Délai entre tirs (secondes) |
| **FLY_POWER_DURATION** | 8.0f | Durée du pouvoir de vol (secondes) |
| **INVINCIBILITY_DURATION** | 12.0f | Durée d'invincibilité (secondes) |
| **COMET_POWER_DURATION** | 10.0f | Durée du pouvoir comète (secondes) |
| **LEVEL_TIMER** | 300.0f | Temps par niveau (secondes = 5 min) |
| **MAX_HIGH_SCORES** | 10 | Nombre max de scores sauvegardés |

### 🎮 Tableau des Scores

| Action | Points |
|--------|--------|
| Collecter une pièce | +200 |
| Collecter Mushroom | +500 |
| Collecter Fire Flower | +1000 |
| Collecter Feather | +800 |
| Collecter Star | +1500 |
| Collecter 1-Up | +2000 |
| Collecter Comet | +1200 |
| Tuer un ennemi | +100 |
| Compléter un niveau | +1000 × niveau |

---

## 🔧 Configuration

### ⚙️ Fichiers de Configuration

| Fichier | Description | Format |
|---------|-------------|--------|
| `highscores.dat` | Sauvegarde des high scores | Binaire |
| `savegame.dat` | Sauvegarde de partie | Binaire |

### 🎚️ Options Disponibles

| Option | Valeur par défaut | Description |
|--------|-------------------|-------------|
| **Musique Volume** | 128 | Volume de la musique (0-128) |
| **Effets Volume** | 128 | Volume des effets (0-128) |
| **Difficulté** | NORMAL | EASY, NORMAL, HARD |
| **Résolution** | 800×600 | Résolution de la fenêtre |
| **FPS** | 60 | Images par seconde (ciblé) |

---

## 🧪 Tests

### 📋 Tests Unitaires Disponibles

| Fichier de Test | Classes Testées | Nombre de Tests |
|-----------------|-----------------|-----------------|
| `test_game_structures.cpp` | HighScore, GameStats, SaveData, Difficulty | 25 |
| `test_player.cpp` | Player | 28 |

### ▶️ Exécution des Tests

```bash
cd tests
make test          # Compile et exécute tous les tests
make test_game_structures
make test_player
```

**Résultats actuels :**
- ✅ **53 tests** au total
- ✅ **100% de réussite**
- ✅ **0 échec**

---

## 📝 Structure du Code

### 🔍 Diagramme de Classes Simplifié

```
                    ┌──────────┐
                    │   Game   │
                    │──────────│
                    │ +Run()   │
                    │ +Update()│
                    │ +Render()│
                    └────┬─────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
  ┌─────────┐    ┌──────────┐    ┌──────────┐
  │ Player  │    │  Enemy   │    │ Platform │
  │─────────│    │──────────│    │──────────│
  │+Update()│    │+Update() │    │+Update() │
  │+Render()│    │+Render() │    │+Render() │
  └─────────┘    └──────────┘    └──────────┘
        │
        │ uses
        ▼
  ┌──────────┐
  │ PowerUp  │
  │──────────│
  │+Collect()│
  └──────────┘
```

### 📐 Schéma de la Boucle de Jeu

```
START
  │
  ├─→ Initialisation SDL
  │
  ├─→ Chargement ressources
  │   ├─→ Images/GIF
  │   ├─→ Musiques
  │   └─→ Polices
  │
  └─→ BOUCLE PRINCIPALE (60 FPS)
        │
        ├─→ ProcessInput()
        │   ├─→ Clavier
        │   ├─→ Souris
        │   └─→ Événements SDL
        │
        ├─→ Update(deltaTime)
        │   ├─→ Physique
        │   ├─→ Collisions
        │   ├─→ IA ennemis
        │   ├─→ Animations
        │   └─→ Audio
        │
        ├─→ Render()
        │   ├─→ Nettoyage écran
        │   ├─→ Dessin arrière-plan
        │   ├─→ Dessin entités
        │   ├─→ Dessin UI
        │   └─→ Présentation frame
        │
        └─→ SDL_Delay(16ms)
              │
              └─→ [retour boucle]
                    │
                    └─→ END (si quit)
```

---

## 🎨 Diagramme des États (State Machine)

```
        ┌────────┐
        │  MENU  │
        └───┬────┘
            │ Entrée
            ▼
    ┌───────────────┐
    │   PLAYING     │
    └───┬───────┬───┘
        │       │
    P/Échap    Fin niveau
        │       │
        ▼       ▼
    ┌──────┐ ┌──────────────┐
    │PAUSED│ │LEVEL_COMPLETE│
    └──┬───┘ └──────┬───────┘
       │            │
       │            │ Entrée
       │            ▼
       │     ┌──────────────┐
       │     │   PLAYING    │ (niveau suivant)
       │     └──────────────┘
       │
       │ Mort
       ▼
┌─────────────┐
│  GAME_OVER  │
└──────┬──────┘
       │
       │ Si high score
       ▼
┌─────────────┐
│ ENTER_NAME  │
└──────┬──────┘
       │ Entrée
       ▼
┌─────────────┐
│    MENU     │
└─────────────┘
```

---

## 🚀 Fonctionnalités Avancées

### 💾 Système de Sauvegarde

```
┌─────────────────────────────────────────┐
│     SYSTÈME DE SAUVEGARDE              │
├─────────────────────────────────────────┤
│                                         │
│  Sauvegarde Automatique                │
│    │                                    │
│    └─→ Checkpoint activé               │
│          │                              │
│          ├─→ Sauvegarder position      │
│          ├─→ Sauvegarder état          │
│          └─→ Sauvegarder statistiques  │
│                                         │
│  Sauvegarde Manuelle                   │
│    │                                    │
│    └─→ Menu Pause → Sauvegarder       │
│          │                              │
│          └─→ Écrire savegame.dat       │
│                                         │
│  Chargement                            │
│    │                                    │
│    └─→ Menu → Charger partie          │
│          │                              │
│          ├─→ Lire savegame.dat         │
│          ├─→ Restaurer niveau          │
│          ├─→ Restaurer position        │
│          └─→ Restaurer statistiques    │
│                                         │
└─────────────────────────────────────────┘
```

### 📊 Système de Statistiques

```
┌─────────────────────────────────────────┐
│    COLLECTE DE STATISTIQUES            │
├─────────────────────────────────────────┤
│                                         │
│  Temps de jeu                          │
│    └─→ deltaTime accumulé              │
│                                         │
│  Ennemis tués                          │
│    └─→ Incrémenté à chaque kill        │
│                                         │
│  Power-ups collectés                   │
│    └─→ Incrémenté à chaque collecte    │
│                                         │
│  Distance parcourue                    │
│    └─→ Différence de position X        │
│                                         │
│  Pièces collectées                     │
│    └─→ Accumulation totale             │
│                                         │
│  Niveaux complétés                     │
│    └─→ Incrémenté à LEVEL_COMPLETE     │
│                                         │
└─────────────────────────────────────────┘
```

---

## 📦 Dépendances

| Bibliothèque | Version | Usage |
|--------------|---------|-------|
| **SDL2** | 2.0+ | Fenêtre, rendu, événements |
| **SDL2_image** | 2.0+ | Chargement images (PNG, JPG, GIF) |
| **SDL2_ttf** | 2.0+ | Rendu texte avec polices |
| **SDL2_mixer** | 2.0+ | Audio (MP3, WAV) |

---

## 🐛 Dépannage

### Problèmes Courants

| Problème | Solution |
|----------|----------|
| **Pas de son** | Vérifier que SDL2_mixer est installé |
| **Police non chargée** | Installer `ttf-dejavu` ou `ttf-liberation` |
| **GIF non animé** | Vérifier que le fichier Mario.gif existe |
| **Crash au démarrage** | Vérifier les dépendances SDL2 |
| **FPS bas** | Réduire la complexité des niveaux |

---

## 📄 License

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

---

## 👥 Auteur

Développé avec ❤️ en C++ et SDL2

---

<div align="center">

**🎮 Amusez-vous bien avec Super Mario Game! 🎮**

![Super Mario](https://img.shields.io/badge/Super-Mario-red.svg?style=for-the-badge)

</div>


























































































