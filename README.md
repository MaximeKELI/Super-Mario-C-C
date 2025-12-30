# Super Mario - Jeu en C++

Un jeu Super Mario simple créé en C++ avec SDL2.

## Fonctionnalités

- ✅ Contrôles fluides (flèches directionnelles ou WASD)
- ✅ Physique de saut et gravité
- ✅ Collisions avec les plateformes
- ✅ Ennemis qui patrouillent
- ✅ Système de vies (3 vies)
- ✅ Système de score
- ✅ Caméra qui suit le joueur
- ✅ Plusieurs plateformes à traverser

## Prérequis

- C++17 ou supérieur
- SDL2
- SDL2_image (optionnel)
- SDL2_ttf (optionnel)
- Make

### Installation des dépendances

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev build-essential
```

#### Fedora
```bash
sudo dnf install SDL2-devel SDL2_image-devel SDL2_ttf-devel gcc-c++ make
```

#### macOS (avec Homebrew)
```bash
brew install sdl2 sdl2_image sdl2_ttf
```

## Compilation

```bash
make
```

## Exécution

```bash
make run
```

ou

```bash
./super_mario
```

## Contrôles

- **Flèche gauche** ou **A** : Aller à gauche
- **Flèche droite** ou **D** : Aller à droite
- **Espace**, **Flèche haut** ou **W** : Sauter
- **Échap** ou fermer la fenêtre : Quitter

## Règles du jeu

1. Vous avez 3 vies
2. Sautez sur les ennemis (verts) pour les éliminer et gagner 100 points
3. Évitez de toucher les ennemis sur les côtés, sinon vous perdez une vie
4. Ne tombez pas dans le vide, sinon vous perdez une vie
5. Atteignez la fin du niveau pour gagner !

## Structure du projet

```
jeu_super_mario/
├── src/
│   ├── main.cpp      # Point d'entrée
│   ├── Game.h/cpp    # Moteur de jeu principal
│   ├── Player.h/cpp  # Classe du joueur (Mario)
│   ├── Platform.h/cpp # Classe des plateformes
│   └── Enemy.h/cpp   # Classe des ennemis
├── Makefile          # Fichier de compilation
└── README.md         # Ce fichier
```

## Améliorations possibles

- Ajouter des sprites graphiques au lieu de rectangles colorés
- Ajouter des sons et de la musique
- Créer plusieurs niveaux
- Ajouter des power-ups (fleur de feu, champignon, etc.)
- Ajouter un système de sauvegarde
- Améliorer l'interface utilisateur avec du texte
- Ajouter des animations

## Licence

Ce projet est un exemple éducatif.
