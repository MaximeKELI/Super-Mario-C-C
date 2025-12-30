#include "Game.h"
#include <iostream>
#include <algorithm>

Game::Game() : mWindow(nullptr), mRenderer(nullptr), mIsRunning(true),
               mPlayer(nullptr), mScore(0), mLives(3), mCameraX(0.0f),
               mLastFrameTime(0) {
}

Game::~Game() {
    Shutdown();
}

bool Game::Initialize() {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        return false;
    }
    
    mWindow = SDL_CreateWindow("Super Mario",
                               SDL_WINDOWPOS_UNDEFINED,
                               SDL_WINDOWPOS_UNDEFINED,
                               800, 600,
                               SDL_WINDOW_SHOWN);
    
    if (mWindow == nullptr) {
        std::cerr << "Window could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        return false;
    }
    
    mRenderer = SDL_CreateRenderer(mWindow, -1, SDL_RENDERER_ACCELERATED);
    if (mRenderer == nullptr) {
        std::cerr << "Renderer could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        return false;
    }
    
    // Créer le joueur
    mPlayer = new Player(100.0f, 100.0f);
    
    // Créer les plateformes
    mPlatforms.push_back(new Platform(0, 550, 200, 50));      // Sol gauche
    mPlatforms.push_back(new Platform(200, 500, 150, 50));    // Plateforme 1
    mPlatforms.push_back(new Platform(400, 450, 150, 50));    // Plateforme 2
    mPlatforms.push_back(new Platform(600, 400, 150, 50));    // Plateforme 3
    mPlatforms.push_back(new Platform(800, 350, 150, 50));    // Plateforme 4
    mPlatforms.push_back(new Platform(1000, 300, 150, 50));   // Plateforme 5
    mPlatforms.push_back(new Platform(1200, 250, 150, 50));   // Plateforme 6
    mPlatforms.push_back(new Platform(1400, 200, 200, 50));    // Plateforme finale
    mPlatforms.push_back(new Platform(1600, 550, 400, 50));   // Sol droit
    
    // Créer les ennemis
    mEnemies.push_back(new Enemy(300, 470));
    mEnemies.push_back(new Enemy(500, 420));
    mEnemies.push_back(new Enemy(700, 370));
    mEnemies.push_back(new Enemy(900, 320));
    mEnemies.push_back(new Enemy(1100, 270));
    
    mLastFrameTime = SDL_GetTicks();
    
    return true;
}

void Game::Run() {
    while (mIsRunning) {
        ProcessInput();
        
        Uint32 currentTime = SDL_GetTicks();
        float deltaTime = (currentTime - mLastFrameTime) / 1000.0f;
        mLastFrameTime = currentTime;
        
        // Limiter le deltaTime pour éviter les sauts de temps
        if (deltaTime > 0.05f) {
            deltaTime = 0.05f;
        }
        
        Update(deltaTime);
        Render();
    }
}

void Game::ProcessInput() {
    SDL_Event e;
    while (SDL_PollEvent(&e)) {
        if (e.type == SDL_QUIT) {
            mIsRunning = false;
        }
    }
    
    const Uint8* keystate = SDL_GetKeyboardState(nullptr);
    if (mPlayer) {
        mPlayer->HandleInput(keystate);
    }
}

void Game::Update(float deltaTime) {
    if (!mPlayer) return;
    
    // Mettre à jour le joueur
    mPlayer->Update(deltaTime);
    
    // Mettre à jour les ennemis
    for (auto* enemy : mEnemies) {
        if (!enemy->IsDead()) {
            enemy->Update(deltaTime);
        }
    }
    
    // Vérifier les collisions
    CheckCollisions();
    
    // Mettre à jour la caméra pour suivre le joueur
    float targetX = mPlayer->GetX() - 400.0f; // Centrer le joueur
    mCameraX += (targetX - mCameraX) * 5.0f * deltaTime;
    
    // Empêcher la caméra d'aller en arrière
    if (mCameraX < 0) {
        mCameraX = 0;
    }
    
    // Vérifier si le joueur est mort (tombé)
    if (mPlayer->GetY() > 600) {
        mLives--;
        if (mLives > 0) {
            mPlayer->Respawn(100.0f, 100.0f);
        } else {
            mIsRunning = false;
            std::cout << "Game Over! Score: " << mScore << std::endl;
        }
    }
}

void Game::CheckCollisions() {
    if (!mPlayer || mPlayer->IsDead()) return;
    
    SDL_FRect playerRect = mPlayer->GetRect();
    bool onGround = false;
    
    // Collisions avec les plateformes
    for (auto* platform : mPlatforms) {
        SDL_FRect platformRect = platform->GetRect();
        
        if (SDL_HasIntersectionF(&playerRect, &platformRect)) {
            // Collision détectée
            float overlapLeft = (playerRect.x + playerRect.w) - platformRect.x;
            float overlapRight = (platformRect.x + platformRect.w) - playerRect.x;
            float overlapTop = (playerRect.y + playerRect.h) - platformRect.y;
            float overlapBottom = (platformRect.y + platformRect.h) - playerRect.y;
            
            float minOverlap = std::min({overlapLeft, overlapRight, overlapTop, overlapBottom});
            
            if (minOverlap == overlapTop) {
                // Collision par le haut (joueur atterrit sur la plateforme)
                mPlayer->SetPosition(mPlayer->GetX(), platformRect.y - playerRect.h);
                mPlayer->SetVelocity(0, 0);
                onGround = true;
            } else if (minOverlap == overlapBottom) {
                // Collision par le bas (joueur heurte le plafond)
                mPlayer->SetPosition(mPlayer->GetX(), platformRect.y + platformRect.h);
                mPlayer->SetVelocity(0, 0);
            } else if (minOverlap == overlapLeft) {
                // Collision par la gauche
                mPlayer->SetPosition(platformRect.x - playerRect.w, mPlayer->GetY());
                mPlayer->SetVelocity(0, 0);
            } else if (minOverlap == overlapRight) {
                // Collision par la droite
                mPlayer->SetPosition(platformRect.x + platformRect.w, mPlayer->GetY());
                mPlayer->SetVelocity(0, 0);
            }
        }
    }
    
    mPlayer->SetOnGround(onGround);
    
    // Collisions avec les ennemis
    for (auto* enemy : mEnemies) {
        if (enemy->IsDead()) continue;
        
        SDL_FRect enemyRect = enemy->GetRect();
        
        if (SDL_HasIntersectionF(&playerRect, &enemyRect)) {
            // Vérifier si le joueur saute sur l'ennemi
            if (mPlayer->GetY() + mPlayer->GetHeight() < enemyRect.y + enemyRect.h * 0.5f &&
                mPlayer->GetY() + mPlayer->GetHeight() > enemyRect.y) {
                // Le joueur a sauté sur l'ennemi
                enemy->Kill();
                mScore += 100;
                mPlayer->SetVelocity(0, -200.0f); // Petit rebond
            } else {
                // Le joueur a été touché
                mLives--;
                if (mLives > 0) {
                    mPlayer->Respawn(100.0f, 100.0f);
                } else {
                    mPlayer->Kill();
                    mIsRunning = false;
                    std::cout << "Game Over! Score: " << mScore << std::endl;
                }
            }
        }
    }
}

void Game::Render() {
    // Effacer l'écran avec un ciel bleu
    SDL_SetRenderDrawColor(mRenderer, 135, 206, 235, 255);
    SDL_RenderClear(mRenderer);
    
    // Dessiner les plateformes
    for (auto* platform : mPlatforms) {
        platform->Render(mRenderer, mCameraX);
    }
    
    // Dessiner les ennemis
    for (auto* enemy : mEnemies) {
        enemy->Render(mRenderer, mCameraX);
    }
    
    // Dessiner le joueur
    if (mPlayer) {
        mPlayer->Render(mRenderer, mCameraX);
    }
    
    // Afficher le score et les vies (texte simple avec des rectangles)
    // Note: Pour un vrai texte, il faudrait SDL_ttf, mais on peut utiliser des formes simples
    
    SDL_RenderPresent(mRenderer);
}

void Game::Shutdown() {
    delete mPlayer;
    
    for (auto* platform : mPlatforms) {
        delete platform;
    }
    mPlatforms.clear();
    
    for (auto* enemy : mEnemies) {
        delete enemy;
    }
    mEnemies.clear();
    
    if (mRenderer) {
        SDL_DestroyRenderer(mRenderer);
        mRenderer = nullptr;
    }
    
    if (mWindow) {
        SDL_DestroyWindow(mWindow);
        mWindow = nullptr;
    }
    
    SDL_Quit();
}

