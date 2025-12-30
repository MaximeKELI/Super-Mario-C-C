#include "Game.h"
#include <iostream>
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <ctime>

Game::Game() : mWindow(nullptr), mRenderer(nullptr), mIsRunning(true),
               mGameState(GameState::MENU), mPaused(false), mPlayer(nullptr),
               mScore(0), mLives(3), mCoinsCollected(0), mCameraX(0.0f),
               mLevelEndX(2000.0f), mCurrentLevel(1), mLastFrameTime(0) {
}

Game::~Game() {
    Shutdown();
}

bool Game::Initialize() {
    srand(time(nullptr));
    
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
    
    LoadLevel();
    mLastFrameTime = SDL_GetTicks();
    
    return true;
}

void Game::LoadLevel() {
    // Nettoyer le niveau précédent
    ResetLevel();
    
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
    
    // Créer les blocs
    mBlocks.push_back(new Block(250, 450, BlockType::QUESTION));
    mBlocks.push_back(new Block(450, 400, BlockType::QUESTION));
    mBlocks.push_back(new Block(650, 350, BlockType::BRICK));
    mBlocks.push_back(new Block(850, 300, BlockType::QUESTION));
    mBlocks.push_back(new Block(1050, 250, BlockType::BRICK));
    mBlocks.push_back(new Block(1250, 200, BlockType::QUESTION));
    mBlocks.push_back(new Block(1450, 150, BlockType::HARD));
    
    // Créer les pièces
    mCoins.push_back(new Coin(300, 400));
    mCoins.push_back(new Coin(500, 350));
    mCoins.push_back(new Coin(700, 300));
    mCoins.push_back(new Coin(900, 250));
    mCoins.push_back(new Coin(1100, 200));
    mCoins.push_back(new Coin(1300, 150));
    mCoins.push_back(new Coin(1500, 100));
    
    // Créer les power-ups
    // Ils seront générés depuis les blocs question
    
    // Créer les ennemis avec différents types
    mEnemies.push_back(new Enemy(300, 470, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(500, 420, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(700, 370, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(900, 320, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(1100, 270, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(1300, 220, EnemyType::GOOMBA));
    
    mLevelEndX = 2000.0f;
}

void Game::ResetLevel() {
    delete mPlayer;
    mPlayer = nullptr;
    
    for (auto* platform : mPlatforms) {
        delete platform;
    }
    mPlatforms.clear();
    
    for (auto* enemy : mEnemies) {
        delete enemy;
    }
    mEnemies.clear();
    
    for (auto* coin : mCoins) {
        delete coin;
    }
    mCoins.clear();
    
    for (auto* powerUp : mPowerUps) {
        delete powerUp;
    }
    mPowerUps.clear();
    
    for (auto* block : mBlocks) {
        delete block;
    }
    mBlocks.clear();
    
    for (auto* fireball : mFireballs) {
        delete fireball;
    }
    mFireballs.clear();
    
    mCameraX = 0.0f;
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
        
        // Éviter deltaTime = 0 au premier frame
        if (deltaTime == 0.0f) {
            deltaTime = 0.016f; // ~60 FPS
        }
        
        if (mGameState == GameState::PLAYING && !mPaused) {
            Update(deltaTime);
        }
        
        Render();
        
        // Limiter le framerate pour éviter de surcharger le CPU
        SDL_Delay(16); // ~60 FPS
    }
}

void Game::ProcessInput() {
    SDL_Event e;
    while (SDL_PollEvent(&e)) {
        if (e.type == SDL_QUIT) {
            mIsRunning = false;
        } else if (e.type == SDL_KEYDOWN) {
            if (mGameState == GameState::MENU) {
                if (e.key.keysym.sym == SDLK_RETURN || e.key.keysym.sym == SDLK_SPACE) {
                    mGameState = GameState::PLAYING;
                }
            } else if (mGameState == GameState::PLAYING) {
                if (e.key.keysym.sym == SDLK_ESCAPE || e.key.keysym.sym == SDLK_p) {
                    mPaused = !mPaused;
                }
            } else if (mGameState == GameState::GAME_OVER || mGameState == GameState::LEVEL_COMPLETE) {
                if (e.key.keysym.sym == SDLK_RETURN || e.key.keysym.sym == SDLK_SPACE) {
                    if (mGameState == GameState::LEVEL_COMPLETE) {
                        mCurrentLevel++;
                        LoadLevel();
                        mGameState = GameState::PLAYING;
                    } else {
                        mCurrentLevel = 1;
                        mScore = 0;
                        mLives = 3;
                        mCoinsCollected = 0;
                        LoadLevel();
                        mGameState = GameState::PLAYING;
                    }
                }
            }
        }
    }
    
    if (mGameState == GameState::PLAYING && !mPaused && mPlayer) {
        const Uint8* keystate = SDL_GetKeyboardState(nullptr);
        mPlayer->HandleInput(keystate);
        
        // Tirer des boules de feu
        if (keystate[SDL_SCANCODE_X] && mPlayer->CanShoot()) {
            mPlayer->Shoot();
            bool directionRight = mPlayer->GetVelocityX() >= 0;
            if (mPlayer->GetVelocityX() == 0) {
                directionRight = true; // Par défaut vers la droite
            }
            mFireballs.push_back(new Fireball(
                mPlayer->GetX() + (directionRight ? mPlayer->GetWidth() : 0),
                mPlayer->GetY() + mPlayer->GetHeight() / 2,
                directionRight
            ));
        }
    }
}

void Game::Update(float deltaTime) {
    if (!mPlayer || mPlayer->IsDead()) return;
    
    // Mettre à jour le joueur
    mPlayer->Update(deltaTime);
    mPlayer->UpdateShootCooldown(deltaTime);
    
    // Mettre à jour les ennemis
    for (auto* enemy : mEnemies) {
        if (!enemy->IsDead()) {
            enemy->Update(deltaTime);
        }
    }
    
    // Mettre à jour les pièces
    for (auto* coin : mCoins) {
        if (!coin->IsCollected()) {
            coin->Update(deltaTime);
        }
    }
    
    // Mettre à jour les power-ups
    for (auto* powerUp : mPowerUps) {
        if (!powerUp->IsCollected()) {
            powerUp->Update(deltaTime);
        }
    }
    
    // Mettre à jour les boules de feu
    for (auto* fireball : mFireballs) {
        if (!fireball->IsDead()) {
            fireball->Update(deltaTime);
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
            mPlayer->Kill();
            mGameState = GameState::GAME_OVER;
        }
    }
    
    // Vérifier si le niveau est complété
    if (mPlayer->GetX() >= mLevelEndX) {
        mGameState = GameState::LEVEL_COMPLETE;
        mScore += 1000 * mCurrentLevel; // Bonus pour compléter le niveau
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
            float overlapLeft = (playerRect.x + playerRect.w) - platformRect.x;
            float overlapRight = (platformRect.x + platformRect.w) - playerRect.x;
            float overlapTop = (playerRect.y + playerRect.h) - platformRect.y;
            float overlapBottom = (platformRect.y + platformRect.h) - playerRect.y;
            
            float minOverlap = std::min({overlapLeft, overlapRight, overlapTop, overlapBottom});
            
            if (minOverlap == overlapTop) {
                mPlayer->SetPosition(mPlayer->GetX(), platformRect.y - playerRect.h);
                mPlayer->SetVelocity(mPlayer->GetVelocityX(), 0);
                onGround = true;
            } else if (minOverlap == overlapBottom) {
                mPlayer->SetPosition(mPlayer->GetX(), platformRect.y + platformRect.h);
                mPlayer->SetVelocity(mPlayer->GetVelocityX(), 0);
            } else if (minOverlap == overlapLeft) {
                mPlayer->SetPosition(platformRect.x - playerRect.w, mPlayer->GetY());
                mPlayer->SetVelocity(0, mPlayer->GetVelocityY());
            } else if (minOverlap == overlapRight) {
                mPlayer->SetPosition(platformRect.x + platformRect.w, mPlayer->GetY());
                mPlayer->SetVelocity(0, mPlayer->GetVelocityY());
            }
        }
    }
    
    // Collisions avec les blocs
    for (auto* block : mBlocks) {
        SDL_FRect blockRect = block->GetRect();
        
        // Collision par le bas (Mario frappe le bloc)
        if (!block->IsDestroyed() && 
            playerRect.y < blockRect.y &&
            playerRect.y + playerRect.h > blockRect.y &&
            playerRect.x + playerRect.w > blockRect.x &&
            playerRect.x < blockRect.x + blockRect.w &&
            mPlayer->GetVelocityY() > 0) {
            
            block->Hit();
            
            if (block->GetType() == BlockType::QUESTION && block->IsHit() && !block->HasSpawnedItem()) {
                // Générer un power-up ou une pièce (une seule fois par bloc)
                block->SetSpawnedItem();
                int randVal = rand() % 3;
                if (randVal == 0) {
                    mPowerUps.push_back(new PowerUp(blockRect.x, blockRect.y - 30, PowerUpType::MUSHROOM));
                } else if (randVal == 1 && mPlayer->IsBig()) {
                    mPowerUps.push_back(new PowerUp(blockRect.x, blockRect.y - 30, PowerUpType::FIRE_FLOWER));
                } else {
                    mCoins.push_back(new Coin(blockRect.x + 6, blockRect.y - 30));
                }
            }
            
            // Repousser le joueur
            mPlayer->SetPosition(mPlayer->GetX(), blockRect.y - playerRect.h);
            mPlayer->SetVelocity(mPlayer->GetVelocityX(), -100.0f);
        }
    }
    
    // Collisions avec les power-ups (pour la gravité)
    for (auto* powerUp : mPowerUps) {
        if (powerUp->IsCollected()) continue;
        
        SDL_FRect powerUpRect = powerUp->GetRect();
        bool powerUpOnGround = false;
        
        for (auto* platform : mPlatforms) {
            SDL_FRect platformRect = platform->GetRect();
            if (SDL_HasIntersectionF(&powerUpRect, &platformRect)) {
                powerUpOnGround = true;
                powerUp->SetPosition(powerUpRect.x, platformRect.y - powerUpRect.h);
                powerUp->SetOnGround(true);
                break;
            }
        }
        
        if (!powerUpOnGround) {
            powerUp->SetOnGround(false);
        }
    }
    
    mPlayer->SetOnGround(onGround);
    
    // Collisions avec les pièces
    for (auto* coin : mCoins) {
        if (coin->IsCollected()) continue;
        
        SDL_FRect coinRect = coin->GetRect();
        if (SDL_HasIntersectionF(&playerRect, &coinRect)) {
            coin->Collect();
            mScore += 200;
            mCoinsCollected++;
        }
    }
    
    // Collisions avec les power-ups
    for (auto* powerUp : mPowerUps) {
        if (powerUp->IsCollected()) continue;
        
        SDL_FRect powerUpRect = powerUp->GetRect();
        if (SDL_HasIntersectionF(&playerRect, &powerUpRect)) {
            powerUp->Collect();
            if (powerUp->GetType() == PowerUpType::MUSHROOM) {
                mPlayer->CollectMushroom();
                mScore += 500;
            } else if (powerUp->GetType() == PowerUpType::FIRE_FLOWER) {
                mPlayer->CollectFireFlower();
                mScore += 1000;
            }
        }
    }
    
    // Collisions avec les ennemis
    for (auto* enemy : mEnemies) {
        if (enemy->IsDead()) continue;
        
        SDL_FRect enemyRect = enemy->GetRect();
        
        if (SDL_HasIntersectionF(&playerRect, &enemyRect)) {
            if (mPlayer->GetY() + mPlayer->GetHeight() < enemyRect.y + enemyRect.h * 0.5f &&
                mPlayer->GetY() + mPlayer->GetHeight() > enemyRect.y) {
                // Le joueur a sauté sur l'ennemi
                enemy->Kill();
                mScore += 100;
                mPlayer->SetVelocity(0, -200.0f);
            } else {
                // Le joueur a été touché
                if (mPlayer->IsBig() || mPlayer->HasFirePower()) {
                    mPlayer->Shrink();
                } else {
                    mLives--;
                    if (mLives > 0) {
                        mPlayer->Respawn(100.0f, 100.0f);
                    } else {
                        mPlayer->Kill();
                        mGameState = GameState::GAME_OVER;
                    }
                }
            }
        }
    }
    
    // Collisions des boules de feu avec les ennemis
    for (auto it = mFireballs.begin(); it != mFireballs.end();) {
        Fireball* fireball = *it;
        if (fireball->IsDead()) {
            it = mFireballs.erase(it);
            delete fireball;
            continue;
        }
        
        SDL_FRect fireballRect = fireball->GetRect();
        
        // Collision avec les plateformes
        bool hitPlatform = false;
        for (auto* platform : mPlatforms) {
            SDL_FRect platformRect = platform->GetRect();
            if (SDL_HasIntersectionF(&fireballRect, &platformRect)) {
                fireball->Kill();
                hitPlatform = true;
                break;
            }
        }
        
        if (hitPlatform) {
            it = mFireballs.erase(it);
            delete fireball;
            continue;
        }
        
        // Collision avec les ennemis
        bool hitEnemy = false;
        for (auto* enemy : mEnemies) {
            if (!enemy->IsDead()) {
                SDL_FRect enemyRect = enemy->GetRect();
                if (SDL_HasIntersectionF(&fireballRect, &enemyRect)) {
                    enemy->Kill();
                    fireball->Kill();
                    mScore += 100;
                    hitEnemy = true;
                    break;
                }
            }
        }
        
        if (hitEnemy) {
            it = mFireballs.erase(it);
            delete fireball;
            continue;
        }
        
        ++it;
    }
}

void Game::Render() {
    // Effacer l'écran
    SDL_SetRenderDrawColor(mRenderer, 135, 206, 235, 255);
    SDL_RenderClear(mRenderer);
    
    if (mGameState == GameState::MENU) {
        RenderMenu();
    } else if (mGameState == GameState::PLAYING || mPaused) {
        // Dessiner les plateformes
        for (auto* platform : mPlatforms) {
            platform->Render(mRenderer, mCameraX);
        }
        
        // Dessiner les blocs
        for (auto* block : mBlocks) {
            block->Render(mRenderer, mCameraX);
        }
        
        // Dessiner les pièces
        for (auto* coin : mCoins) {
            coin->Render(mRenderer, mCameraX);
        }
        
        // Dessiner les power-ups
        for (auto* powerUp : mPowerUps) {
            powerUp->Render(mRenderer, mCameraX);
        }
        
        // Dessiner les ennemis
        for (auto* enemy : mEnemies) {
            enemy->Render(mRenderer, mCameraX);
        }
        
        // Dessiner les boules de feu
        for (auto* fireball : mFireballs) {
            fireball->Render(mRenderer, mCameraX);
        }
        
        // Dessiner le joueur
        if (mPlayer) {
            mPlayer->Render(mRenderer, mCameraX);
        }
        
        RenderUI();
        
        if (mPaused) {
            // Afficher "PAUSE"
            SDL_SetRenderDrawColor(mRenderer, 0, 0, 0, 200);
            SDL_Rect pauseRect = {300, 250, 200, 100};
            SDL_RenderFillRect(mRenderer, &pauseRect);
        }
    } else if (mGameState == GameState::GAME_OVER) {
        // Fond
        SDL_SetRenderDrawColor(mRenderer, 50, 0, 0, 255);
        SDL_RenderClear(mRenderer);
        
        // Afficher "GAME OVER"
        SDL_SetRenderDrawColor(mRenderer, 0, 0, 0, 255);
        SDL_Rect gameOverRect = {200, 200, 400, 200};
        SDL_RenderFillRect(mRenderer, &gameOverRect);
        
        SDL_SetRenderDrawColor(mRenderer, 255, 0, 0, 255);
        SDL_RenderDrawRect(mRenderer, &gameOverRect);
        
        // Message
        SDL_SetRenderDrawColor(mRenderer, 255, 255, 255, 255);
        SDL_Rect msgRect = {220, 250, 360, 30};
        SDL_RenderFillRect(mRenderer, &msgRect);
        
        SDL_Rect restartRect = {220, 300, 360, 30};
        SDL_RenderFillRect(mRenderer, &restartRect);
    } else if (mGameState == GameState::LEVEL_COMPLETE) {
        // Fond
        SDL_SetRenderDrawColor(mRenderer, 0, 50, 0, 255);
        SDL_RenderClear(mRenderer);
        
        // Afficher "LEVEL COMPLETE"
        SDL_SetRenderDrawColor(mRenderer, 0, 0, 0, 255);
        SDL_Rect completeRect = {150, 200, 500, 200};
        SDL_RenderFillRect(mRenderer, &completeRect);
        
        SDL_SetRenderDrawColor(mRenderer, 0, 255, 0, 255);
        SDL_RenderDrawRect(mRenderer, &completeRect);
        
        // Message
        SDL_SetRenderDrawColor(mRenderer, 255, 255, 255, 255);
        SDL_Rect msgRect = {170, 250, 460, 30};
        SDL_RenderFillRect(mRenderer, &msgRect);
        
        SDL_Rect nextRect = {170, 300, 460, 30};
        SDL_RenderFillRect(mRenderer, &nextRect);
    }
    
    SDL_RenderPresent(mRenderer);
}

void Game::RenderUI() {
    // Barre d'information en haut
    SDL_SetRenderDrawColor(mRenderer, 0, 0, 0, 200);
    SDL_Rect uiRect = {0, 0, 800, 50};
    SDL_RenderFillRect(mRenderer, &uiRect);
    
    // Bordure
    SDL_SetRenderDrawColor(mRenderer, 255, 255, 255, 255);
    SDL_RenderDrawLine(mRenderer, 0, 50, 800, 50);
    
    // Indicateurs visuels pour le score (rectangles colorés)
    SDL_SetRenderDrawColor(mRenderer, 255, 255, 0, 255);
    SDL_Rect scoreIndicator = {10, 10, std::min(mScore / 10, 200), 10};
    SDL_RenderFillRect(mRenderer, &scoreIndicator);
    
    // Indicateurs pour les vies (cœurs rouges)
    SDL_SetRenderDrawColor(mRenderer, 255, 0, 0, 255);
    for (int i = 0; i < mLives && i < 5; i++) {
        SDL_Rect lifeRect = {220 + i * 25, 15, 15, 15};
        SDL_RenderFillRect(mRenderer, &lifeRect);
    }
    
    // Indicateur pour les pièces
    SDL_SetRenderDrawColor(mRenderer, 255, 215, 0, 255);
    SDL_Rect coinIndicator = {350, 15, 15, 15};
    SDL_RenderFillRect(mRenderer, &coinIndicator);
    SDL_Rect coinCount = {370, 15, std::min(mCoinsCollected * 2, 50), 15};
    SDL_RenderFillRect(mRenderer, &coinCount);
    
    // Indicateur de niveau
    SDL_SetRenderDrawColor(mRenderer, 0, 255, 0, 255);
    SDL_Rect levelRect = {450, 15, 20, 20};
    SDL_RenderFillRect(mRenderer, &levelRect);
}

void Game::RenderMenu() {
    // Fond du menu - plus visible
    SDL_SetRenderDrawColor(mRenderer, 50, 50, 150, 255);
    SDL_RenderClear(mRenderer);
    
    // Boîte du menu
    SDL_SetRenderDrawColor(mRenderer, 0, 0, 100, 255);
    SDL_Rect menuRect = {200, 150, 400, 300};
    SDL_RenderFillRect(mRenderer, &menuRect);
    
    // Bordure
    SDL_SetRenderDrawColor(mRenderer, 255, 255, 255, 255);
    SDL_RenderDrawRect(mRenderer, &menuRect);
    
    // Titre (simulé avec des rectangles)
    SDL_SetRenderDrawColor(mRenderer, 255, 255, 0, 255);
    SDL_Rect titleRect = {250, 180, 300, 40};
    SDL_RenderFillRect(mRenderer, &titleRect);
    
    // Instructions (simulé avec des rectangles)
    SDL_SetRenderDrawColor(mRenderer, 255, 255, 255, 255);
    SDL_Rect instRect1 = {220, 250, 360, 20};
    SDL_Rect instRect2 = {220, 280, 360, 20};
    SDL_Rect instRect3 = {220, 310, 360, 20};
    SDL_RenderFillRect(mRenderer, &instRect1);
    SDL_RenderFillRect(mRenderer, &instRect2);
    SDL_RenderFillRect(mRenderer, &instRect3);
    
    // Indicateur "Appuyez sur Entree"
    SDL_SetRenderDrawColor(mRenderer, 0, 255, 0, 255);
    SDL_Rect pressRect = {250, 380, 300, 30};
    SDL_RenderFillRect(mRenderer, &pressRect);
}

void Game::Shutdown() {
    ResetLevel();
    
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
