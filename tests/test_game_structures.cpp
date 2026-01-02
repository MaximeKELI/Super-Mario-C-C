#include "test_framework.h"
#include "../src/Game.h"
#include <cstring>

// Tests pour les structures de données du jeu

TEST(HighScore_DefaultConstructor) {
    HighScore hs;
    TestFramework::assertEqual(0, hs.score, "HighScore score par défaut devrait être 0");
    TestFramework::assertEqual(1, hs.level, "HighScore level par défaut devrait être 1");
    TestFramework::assertTrue(hs.name.empty(), "HighScore name par défaut devrait être vide");
    TestFramework::assertEqual(static_cast<int>(Difficulty::NORMAL), static_cast<int>(hs.difficulty), 
                               "HighScore difficulty par défaut devrait être NORMAL");
}
END_TEST

TEST(HighScore_ParameterizedConstructor) {
    HighScore hs("TestPlayer", 5000, 5, Difficulty::HARD);
    TestFramework::assertEqual(5000, hs.score, "HighScore score devrait être 5000");
    TestFramework::assertEqual(5, hs.level, "HighScore level devrait être 5");
    TestFramework::assertTrue(hs.name == "TestPlayer", "HighScore name devrait être 'TestPlayer'");
    TestFramework::assertEqual(static_cast<int>(Difficulty::HARD), static_cast<int>(hs.difficulty),
                               "HighScore difficulty devrait être HARD");
}
END_TEST

TEST(GameStats_DefaultConstructor) {
    GameStats stats;
    TestFramework::assertEqual(0.0f, stats.totalPlayTime, 0.001f, "GameStats totalPlayTime par défaut devrait être 0");
    TestFramework::assertEqual(0, stats.enemiesKilled, "GameStats enemiesKilled par défaut devrait être 0");
    TestFramework::assertEqual(0, stats.powerUpsCollected, "GameStats powerUpsCollected par défaut devrait être 0");
    TestFramework::assertEqual(0.0f, stats.distanceTraveled, 0.001f, "GameStats distanceTraveled par défaut devrait être 0");
    TestFramework::assertEqual(0, stats.totalCoinsCollected, "GameStats totalCoinsCollected par défaut devrait être 0");
    TestFramework::assertEqual(0, stats.levelsCompleted, "GameStats levelsCompleted par défaut devrait être 0");
}
END_TEST

TEST(SaveData_DefaultConstructor) {
    SaveData save;
    TestFramework::assertEqual(1, save.currentLevel, "SaveData currentLevel par défaut devrait être 1");
    TestFramework::assertEqual(0, save.score, "SaveData score par défaut devrait être 0");
    TestFramework::assertEqual(3, save.lives, "SaveData lives par défaut devrait être 3");
    TestFramework::assertEqual(0, save.coinsCollected, "SaveData coinsCollected par défaut devrait être 0");
    TestFramework::assertEqual(100.0f, save.checkpointX, 0.001f, "SaveData checkpointX par défaut devrait être 100.0");
    TestFramework::assertEqual(100.0f, save.checkpointY, 0.001f, "SaveData checkpointY par défaut devrait être 100.0");
    TestFramework::assertFalse(save.hasCheckpoint, "SaveData hasCheckpoint par défaut devrait être false");
    TestFramework::assertEqual(static_cast<int>(Difficulty::NORMAL), static_cast<int>(save.difficulty),
                               "SaveData difficulty par défaut devrait être NORMAL");
}
END_TEST

TEST(Difficulty_EnumValues) {
    TestFramework::assertEqual(0, static_cast<int>(Difficulty::EASY), "Difficulty::EASY devrait être 0");
    TestFramework::assertEqual(1, static_cast<int>(Difficulty::NORMAL), "Difficulty::NORMAL devrait être 1");
    TestFramework::assertEqual(2, static_cast<int>(Difficulty::HARD), "Difficulty::HARD devrait être 2");
}
END_TEST

int main() {
    std::cout << "=== Tests des structures de données du jeu ===" << std::endl;
    
    TestFramework::reset();
    
    RUN_TEST(HighScore_DefaultConstructor);
    RUN_TEST(HighScore_ParameterizedConstructor);
    RUN_TEST(GameStats_DefaultConstructor);
    RUN_TEST(SaveData_DefaultConstructor);
    RUN_TEST(Difficulty_EnumValues);
    
    TestFramework::printSummary();
    
    return (TestFramework::failedTests > 0) ? 1 : 0;
}

