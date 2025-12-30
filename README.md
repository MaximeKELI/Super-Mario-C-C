# Super Mario - Jeu en C++

Un jeu Super Mario complet et développé créé en C++ avec SDL2, avec de nombreuses fonctionnalités !

## 🎮 Fonctionnalités

### Système de jeu
- ✅ **Menu de démarrage** - Écran d'accueil avec instructions
- ✅ **Système de pause** - Appuyez sur P ou Échap pour mettre en pause
- ✅ **Système de niveaux** - Plusieurs niveaux avec fin de niveau
- ✅ **Game Over** - Écran de fin de partie avec possibilité de recommencer
- ✅ **Score et statistiques** - Système de score complet avec bonus

### Personnage (Mario)
- ✅ **Contrôles fluides** - Flèches directionnelles ou WASD
- ✅ **Physique réaliste** - Gravité, saut, collisions
- ✅ **Power-ups** :
  - 🍄 **Champignon** - Grandit Mario (plus de vies)
  - 🔥 **Fleur de feu** - Permet de lancer des boules de feu (touche X)
- ✅ **États** - Petit, Grand, avec pouvoir de feu
- ✅ **Système de vies** - 3 vies au départ

### Éléments du jeu
- ✅ **Plateformes** - Plusieurs types de plateformes à traverser
- ✅ **Blocs interactifs** :
  - ❓ **Blocs Question** - Contiennent des power-ups ou des pièces
  - 🧱 **Blocs de brique** - Destructibles en sautant dessus
  - ⬛ **Blocs durs** - Indestructibles
- ✅ **Pièces collectibles** - Animation de rebond, +200 points
- ✅ **Ennemis variés** :
  - 🟤 **Goomba** - Ennemi basique qui patrouille
  - 🟢 **Koopa** - Tortue verte avec carapace
  - 🔵 **Ennemi volant** - Mouvement sinusoïdal dans les airs
- ✅ **Boules de feu** - Tirer avec X quand vous avez la fleur de feu

### Système de collisions
- ✅ **Collisions précises** - Détection de collision avancée
- ✅ **Physique des ennemis** - Élimination en sautant dessus
- ✅ **Collisions avec power-ups** - Gravité et interactions
- ✅ **Collisions avec blocs** - Animation de frappe

### Graphismes et interface
- ✅ **Caméra dynamique** - Suit le joueur automatiquement
- ✅ **Rendu amélioré** - Couleurs et formes distinctes pour chaque élément
- ✅ **Animations** - Pièces qui rebondissent, blocs qui bougent
- ✅ **Interface utilisateur** - Affichage du score, vies, pièces

## 📋 Prérequis

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

## 🔨 Compilation

```bash
make
```

## 🎯 Exécution

```bash
make run
```

ou

```bash
./super_mario
```

## 🎮 Contrôles

### Menu
- **Entrée** ou **Espace** : Commencer le jeu

### En jeu
- **Flèche gauche** ou **A** : Aller à gauche
- **Flèche droite** ou **D** : Aller à droite
- **Espace**, **Flèche haut** ou **W** : Sauter
- **X** : Lancer une boule de feu (nécessite la fleur de feu)
- **P** ou **Échap** : Mettre en pause

### Fin de partie
- **Entrée** ou **Espace** : Recommencer

## 📊 Système de score

- **Éliminer un ennemi** : +100 points
- **Collecter une pièce** : +200 points
- **Champignon** : +500 points
- **Fleur de feu** : +1000 points
- **Compléter un niveau** : +1000 × numéro du niveau

## 🎯 Règles du jeu

1. Vous avez **3 vies** au départ
2. **Sautez sur les ennemis** pour les éliminer et gagner des points
3. **Évitez de toucher les ennemis sur les côtés** :
   - Si vous êtes grand ou avez la fleur de feu : vous rétrécissez
   - Si vous êtes petit : vous perdez une vie
4. **Ne tombez pas dans le vide**, sinon vous perdez une vie
5. **Collectez les pièces** pour augmenter votre score
6. **Frappez les blocs question** pour obtenir des power-ups
7. **Atteignez la fin du niveau** pour passer au suivant
8. **Utilisez les boules de feu** (touche X) pour éliminer les ennemis à distance

## 📁 Structure du projet

```
jeu_super_mario/
├── src/
│   ├── main.cpp          # Point d'entrée
│   ├── Game.h/cpp        # Moteur de jeu principal
│   ├── Player.h/cpp      # Classe du joueur (Mario)
│   ├── Platform.h/cpp    # Classe des plateformes
│   ├── Enemy.h/cpp       # Classe des ennemis (plusieurs types)
│   ├── Coin.h/cpp        # Classe des pièces collectibles
│   ├── PowerUp.h/cpp     # Classe des power-ups
│   ├── Block.h/cpp       # Classe des blocs interactifs
│   └── Fireball.h/cpp    # Classe des boules de feu
├── obj/                  # Fichiers objets compilés
├── Makefile              # Fichier de compilation
└── README.md             # Ce fichier
```

## 🚀 Améliorations futures possibles

- [ ] Ajouter des sprites graphiques au lieu de rectangles colorés
- [ ] Ajouter des sons et de la musique
- [ ] Créer plusieurs niveaux avec designs différents
- [ ] Ajouter des boss de fin de niveau
- [ ] Système de sauvegarde/chargement
- [ ] Améliorer l'interface utilisateur avec du vrai texte (SDL_ttf)
- [ ] Ajouter des animations plus fluides
- [ ] Système de records/high scores
- [ ] Mode multijoueur
- [ ] Éditeur de niveaux

## 🐛 Notes techniques

- Le jeu utilise SDL2 pour le rendu graphique
- La physique est gérée manuellement (gravité, collisions)
- Les collisions utilisent SDL_HasIntersectionF pour la détection
- Le système de caméra suit le joueur avec interpolation

## 📝 Licence

Ce projet est un exemple éducatif.

## 🎉 Amusez-vous bien !

Profitez de ce jeu Super Mario développé avec de nombreuses fonctionnalités !
