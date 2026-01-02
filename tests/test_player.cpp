#include "test_framework.h"
#include "../src/Player.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <iostream>

// Tests pour la classe Player
// Note: Ces tests nécessitent SDL initialisé

SDL_Renderer* g_testRenderer = nullptr;

bool initSDLForTests() {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "Échec de l'initialisation SDL pour les tests" << std::endl;
        return false;
    }
    
    SDL_Window* window = SDL_CreateWindow("Test", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 100, 100, SDL_WINDOW_HIDDEN);
    if (!window) {
        std::cerr << "Échec de la création de la fenêtre de test" << std::endl;
        SDL_Quit();
        return false;
    }
    
    g_testRenderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!g_testRenderer) {
        std::cerr << "Échec de la création du renderer de test" << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return false;
    }
    
    IMG_Init(IMG_INIT_PNG | IMG_INIT_JPG);
    return true;
}

void cleanupSDLForTests() {
    if (g_testRenderer) {
        SDL_DestroyRenderer(g_testRenderer);
        g_testRenderer = nullptr;
    }
    SDL_Quit();
    IMG_Quit();
}

TEST(Player_Initialization) {
    if (!g_testRenderer) {
        TestFramework::assertTrue(false, "Renderer non initialisé pour le test");
        return;
    }
    
    Player player(100.0f, 200.0f, g_testRenderer);
    
    TestFramework::assertEqual(100.0f, player.GetX(), 0.001f, "Player X initial devrait être 100.0");
    TestFramework::assertEqual(200.0f, player.GetY(), 0.001f, "Player Y initial devrait être 200.0");
    TestFramework::assertFalse(player.IsDead(), "Player ne devrait pas être mort initialement");
    TestFramework::assertFalse(player.IsBig(), "Player ne devrait pas être grand initialement");
    TestFramework::assertFalse(player.HasFirePower(), "Player ne devrait pas avoir de pouvoir de feu initialement");
    TestFramework::assertFalse(player.HasFlyPower(), "Player ne devrait pas avoir de pouvoir de vol initialement");
    TestFramework::assertFalse(player.IsInvincible(), "Player ne devrait pas être invincible initialement");
}
END_TEST

TEST(Player_SetPosition) {
    if (!g_testRenderer) {
        TestFramework::assertTrue(false, "Renderer non initialisé pour le test");
        return;
    }
    
    Player player(0.0f, 0.0f, g_testRenderer);
    player.SetPosition(150.0f, 250.0f);
    
    TestFramework::assertEqual(150.0f, player.GetX(), 0.001f, "Player X devrait être 150.0 après SetPosition");
    TestFramework::assertEqual(250.0f, player.GetY(), 0.001f, "Player Y devrait être 250.0 après SetPosition");
}
END_TEST

TEST(Player_SetVelocity) {
    if (!g_testRenderer) {
        TestFramework::assertTrue(false, "Renderer non initialisé pour le test");
        return;
    }
    
    Player player(0.0f, 0.0f, g_testRenderer);
    player.SetVelocity(100.0f, -200.0f);
    
    TestFramework::assertEqual(100.0f, player.GetVelocityX(), 0.001f, "Player velocityX devrait être 100.0");
    TestFramework::assertEqual(-200.0f, player.GetVelocityY(), 0.001f, "Player velocityY devrait être -200.0");
}
END_TEST

TEST(Player_KillAndRespawn) {
    if (!g_testRenderer) {
        TestFramework::assertTrue(false, "Renderer non initialisé pour le test");
        return;
    }
    
    Player player(100.0f, 200.0f, g_testRenderer);
    player.Kill();
    
    TestFramework::assertTrue(player.IsDead(), "Player devrait être mort après Kill()");
    
    player.Respawn(50.0f, 75.0f);
    
    TestFramework::assertFalse(player.IsDead(), "Player ne devrait plus être mort après Respawn()");
    TestFramework::assertEqual(50.0f, player.GetX(), 0.001f, "Player X devrait être 50.0 après Respawn");
    TestFramework::assertEqual(75.0f, player.GetY(), 0.001f, "Player Y devrait être 75.0 après Respawn");
}
END_TEST

TEST(Player_CollectMushroom) {
    if (!g_testRenderer) {
        TestFramework::assertTrue(false, "Renderer non initialisé pour le test");
        return;
    }
    
    Player player(0.0f, 0.0f, g_testRenderer);
    TestFramework::assertFalse(player.IsBig(), "Player ne devrait pas être grand initialement");
    
    player.CollectMushroom();
    
    TestFramework::assertTrue(player.IsBig(), "Player devrait être grand après CollectMushroom()");
}
END_TEST

TEST(Player_CollectFireFlower) {
    if (!g_testRenderer) {
        TestFramework::assertTrue(false, "Renderer non initialisé pour le test");
        return;
    }
    
    Player player(0.0f, 0.0f, g_testRenderer);
    TestFramework::assertFalse(player.HasFirePower(), "Player ne devrait pas avoir de pouvoir de feu initialement");
    
    player.CollectFireFlower();
    
    TestFramework::assertTrue(player.HasFirePower(), "Player devrait avoir le pouvoir de feu après CollectFireFlower()");
    TestFramework::assertTrue(player.IsBig(), "Player devrait être grand après CollectFireFlower()");
}
END_TEST

TEST(Player_CollectFeather) {
    if (!g_testRenderer) {
        TestFramework::assertTrue(false, "Renderer non initialisé pour le test");
        return;
    }
    
    Player player(0.0f, 0.0f, g_testRenderer);
    TestFramework::assertFalse(player.HasFlyPower(), "Player ne devrait pas avoir de pouvoir de vol initialement");
    
    player.CollectFeather();
    
    TestFramework::assertTrue(player.HasFlyPower(), "Player devrait avoir le pouvoir de vol après CollectFeather()");
}
END_TEST

TEST(Player_CollectStar) {
    if (!g_testRenderer) {
        TestFramework::assertTrue(false, "Renderer non initialisé pour le test");
        return;
    }
    
    Player player(0.0f, 0.0f, g_testRenderer);
    TestFramework::assertFalse(player.IsInvincible(), "Player ne devrait pas être invincible initialement");
    
    player.CollectStar();
    
    TestFramework::assertTrue(player.IsInvincible(), "Player devrait être invincible après CollectStar()");
}
END_TEST

TEST(Player_Shrink) {
    if (!g_testRenderer) {
        TestFramework::assertTrue(false, "Renderer non initialisé pour le test");
        return;
    }
    
    Player player(0.0f, 0.0f, g_testRenderer);
    player.CollectMushroom();
    TestFramework::assertTrue(player.IsBig(), "Player devrait être grand après CollectMushroom()");
    
    player.Shrink();
    
    TestFramework::assertFalse(player.IsBig(), "Player ne devrait plus être grand après Shrink()");
    TestFramework::assertFalse(player.HasFirePower(), "Player ne devrait plus avoir de pouvoir de feu après Shrink()");
    TestFramework::assertFalse(player.HasFlyPower(), "Player ne devrait plus avoir de pouvoir de vol après Shrink()");
}
END_TEST

int main() {
    std::cout << "=== Tests de la classe Player ===" << std::endl;
    
    if (!initSDLForTests()) {
        std::cerr << "Impossible d'initialiser SDL pour les tests" << std::endl;
        return 1;
    }
    
    TestFramework::reset();
    
    RUN_TEST(Player_Initialization);
    RUN_TEST(Player_SetPosition);
    RUN_TEST(Player_SetVelocity);
    RUN_TEST(Player_KillAndRespawn);
    RUN_TEST(Player_CollectMushroom);
    RUN_TEST(Player_CollectFireFlower);
    RUN_TEST(Player_CollectFeather);
    RUN_TEST(Player_CollectStar);
    RUN_TEST(Player_Shrink);
    
    cleanupSDLForTests();
    
    TestFramework::printSummary();
    
    return (TestFramework::failedTests > 0) ? 1 : 0;
}

