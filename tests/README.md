# Tests Unitaires - Super Mario Game

Ce répertoire contient les tests unitaires pour le projet Super Mario.

## Structure

- `test_framework.h` : Framework de tests simple avec assertions et affichage des résultats
- `test_game_structures.cpp` : Tests pour les structures de données (HighScore, GameStats, SaveData, Difficulty)
- `test_player.cpp` : Tests pour la classe Player
- `Makefile` : Compilation et exécution des tests

## Compilation et exécution

### Compiler tous les tests
```bash
make all
```

### Exécuter tous les tests
```bash
make test
```

### Compiler un test spécifique
```bash
make test_game_structures
make test_player
```

### Exécuter un test spécifique
```bash
./test_game_structures
./test_player
```

### Nettoyer les fichiers compilés
```bash
make clean
```

## Tests disponibles

### Tests des structures de données
- HighScore (constructeur par défaut et paramétré)
- GameStats (constructeur par défaut)
- SaveData (constructeur par défaut)
- Difficulty (valeurs de l'enum)

### Tests de la classe Player
- Initialisation
- SetPosition
- SetVelocity
- Kill et Respawn
- CollectMushroom
- CollectFireFlower
- CollectFeather
- CollectStar
- Shrink

## Résultats

Les tests affichent :
- ✓ pour les tests réussis
- ✗ pour les tests échoués
- Un résumé à la fin avec le nombre total de tests, réussis et échoués
- La liste des échecs si il y en a

## Ajouter de nouveaux tests

1. Créer un nouveau fichier `test_*.cpp`
2. Inclure `test_framework.h`
3. Utiliser les macros `TEST(name)` et `END_TEST`
4. Ajouter le test au Makefile
5. Utiliser les méthodes de `TestFramework` pour les assertions

Exemple :
```cpp
#include "test_framework.h"

TEST(MyTest) {
    TestFramework::assertTrue(true, "Mon test");
    TestFramework::assertEqual(5, 5, "Égalité");
}
END_TEST

int main() {
    TestFramework::reset();
    RUN_TEST(MyTest);
    TestFramework::printSummary();
    return (TestFramework::failedTests > 0) ? 1 : 0;
}
```

