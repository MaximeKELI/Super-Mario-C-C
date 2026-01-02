# Fonctionnalités à implémenter

Ce fichier documente les fonctionnalités demandées et leur statut d'implémentation.

## Fonctionnalités implémentées (structure de base)

✅ Structures de données :
- HighScore struct
- GameStats struct  
- SaveData struct
- Difficulty enum
- Nouveaux GameState (HIGH_SCORES, STATISTICS, ENTER_NAME)

✅ Fonctions de rendu de base :
- RenderHighScores()
- RenderStatistics()
- RenderPauseMenu()
- RenderMiniMap()
- RenderEnterName()

✅ Fonctions de sauvegarde/chargement de base :
- LoadHighScores()
- SaveHighScores()
- SaveGame()
- LoadGame()

## Fonctionnalités partiellement implémentées

⚠️ ProcessInput() - Nécessite ajout de gestion pour :
- PAUSED avec menu pause interactif
- HIGH_SCORES (navigation)
- STATISTICS (navigation)
- ENTER_NAME (saisie de texte)
- MENU (ajout options High Scores, Statistics, Charger partie)

⚠️ Update() - Nécessite ajout de :
- Mise à jour des statistiques (temps, distance, etc.)
- Sauvegarde automatique aux checkpoints

⚠️ GAME_OVER - Nécessite :
- Vérification et ajout de high score
- Transition vers ENTER_NAME si nouveau high score

⚠️ LEVEL_COMPLETE - Nécessite :
- Mise à jour des statistiques (niveaux complétés)

⚠️ Menu principal - Nécessite :
- Options pour High Scores, Statistics, Charger partie

⚠️ ApplyDifficulty() - Nécessite :
- Application des effets de difficulté aux ennemis

## Prochaines étapes

1. Compléter ProcessInput() pour tous les nouveaux états
2. Ajouter mise à jour des statistiques dans Update()
3. Intégrer high scores dans GAME_OVER
4. Ajouter sauvegarde automatique aux checkpoints
5. Améliorer le menu principal

