#include "Game.h"
#include <iostream>
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <sstream>

Game::Game() : mWindow(nullptr), mRenderer(nullptr), mFont(nullptr), mBackgroundMusic(nullptr), mLevelClearMusic(nullptr), mIsRunning(true),
               mGameState(GameState::MENU), mPaused(false), mPlayer(nullptr),
               mScore(0), mLives(3), mCoinsCollected(0), mCameraX(0.0f),
               mLevelEndX(2000.0f), mCurrentLevel(1), mLevelTimer(300.0f),
               mCheckpointX(100.0f), mCheckpointY(100.0f), mHasCheckpoint(false),
               mLevelStartTime(0.0f), mLastPlayerX(0.0f), mDifficulty(Difficulty::NORMAL),
               mPauseMenuSelection(0), mPauseMenuMaxItems(4), mInOptionsMenu(false),
               mOptionsMenuSelection(0), mMusicVolume(128), mSoundVolume(128),
               mPlayerName(""), mPlayerNameCursorPos(0), mWaitingForName(false),
               mLastFrameTime(0) {
    LoadHighScores();
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
    
    // Initialiser SDL_image
    int imgFlags = IMG_INIT_PNG | IMG_INIT_JPG;
    if (!(IMG_Init(imgFlags) & imgFlags)) {
        std::cerr << "SDL_image could not initialize! IMG_Error: " << IMG_GetError() << std::endl;
        // On continue quand même, le jeu peut fonctionner sans images
    }
    
    // Initialiser SDL_ttf
    if (TTF_Init() == -1) {
        std::cerr << "SDL_ttf could not initialize! TTF_Error: " << TTF_GetError() << std::endl;
        // On continue sans texte, on utilisera des rectangles
    } else {
        // Charger une police par défaut (ou utiliser une police système)
        // On essaie d'abord avec une police monospace système
        mFont = TTF_OpenFont("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", 20);
        if (!mFont) {
            // Essayer une autre police commune
            mFont = TTF_OpenFont("/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf", 20);
        }
        if (!mFont) {
            // Essayer une police encore plus commune
            mFont = TTF_OpenFont("/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf", 20);
        }
        if (!mFont) {
            std::cerr << "Impossible de charger une police! Le texte ne sera pas affiché. TTF_Error: " << TTF_GetError() << std::endl;
        }
    }
    
    // Initialiser SDL_mixer
    if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
        std::cerr << "Erreur d'initialisation de SDL_mixer: " << Mix_GetError() << std::endl;
        // Ne pas retourner false, on continue sans audio
    } else {
        // Charger la musique de fond
        mBackgroundMusic = Mix_LoadMUS("src/06. Ragtime in the Skies.mp3");
        if (!mBackgroundMusic) {
            std::cerr << "Impossible de charger la musique de fond: " << Mix_GetError() << std::endl;
        } else {
            // Jouer la musique en boucle
            if (Mix_PlayMusic(mBackgroundMusic, -1) == -1) {
                std::cerr << "Impossible de jouer la musique de fond: " << Mix_GetError() << std::endl;
            }
        }
        
        // Charger la musique "Level Clear"
        mLevelClearMusic = Mix_LoadMUS("src/20. Level Clear!.mp3");
        if (!mLevelClearMusic) {
            std::cerr << "Impossible de charger la musique Level Clear: " << Mix_GetError() << std::endl;
        }
    }
    
    mWindow = SDL_CreateWindow("Super Mario",
                               SDL_WINDOWPOS_UNDEFINED,
                               SDL_WINDOWPOS_UNDEFINED,
                               800, 600,
                               SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    
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
    
    std::cout << "Jeu initialisé avec succès!" << std::endl;
    std::cout << "Appuyez sur Entrée ou Espace pour commencer" << std::endl;
    
    return true;
}

void Game::LoadLevel() {
    // Nettoyer le niveau précédent
    ResetLevel();
    
    // Créer le joueur
    mPlayer = new Player(100.0f, 100.0f, mRenderer);
    
    float levelLength = 0.0f;
    
    // Générer le niveau en fonction de mCurrentLevel
    switch (mCurrentLevel) {
        case 1:
            LoadLevel1();
            levelLength = 1800.0f;
            break;
        case 2:
            LoadLevel2();
            levelLength = 2200.0f;
            break;
        case 3:
            LoadLevel3();
            levelLength = 2400.0f;
            break;
        case 4:
            LoadLevel4();
            levelLength = 2600.0f;
            break;
        case 5:
            LoadLevel5();
            levelLength = 2800.0f;
            break;
        case 6:
            LoadLevel6();
            levelLength = 3000.0f;
            break;
        case 7:
            LoadLevel7();
            levelLength = 3200.0f;
            break;
        case 8:
            LoadLevel8();
            levelLength = 3400.0f;
            break;
        case 9:
            LoadLevel9();
            levelLength = 3600.0f;
            break;
        case 10:
            LoadLevel10();
            levelLength = 4000.0f;
            break;
        default:
            // Niveaux supplémentaires au-delà de 10
            LoadLevelExtra(mCurrentLevel);
            levelLength = 2000.0f + (mCurrentLevel * 200.0f);
            break;
    }
    
    mLevelEndX = levelLength;
    mLevelTimer = 300.0f;  // 5 minutes par niveau
    mHasCheckpoint = false;
}

void Game::LoadLevel1() {
    // Niveau 1 - Introduction (facile)
    mPlatforms.push_back(new Platform(0, 550, 200, 50));      // Sol gauche
    mPlatforms.push_back(new Platform(200, 500, 150, 50));
    mPlatforms.push_back(new Platform(400, 450, 150, 50));
    mPlatforms.push_back(new Platform(600, 400, 150, 50));
    mPlatforms.push_back(new Platform(800, 350, 150, 50));
    mPlatforms.push_back(new Platform(1000, 300, 150, 50));
    mPlatforms.push_back(new Platform(1200, 250, 150, 50));
    mPlatforms.push_back(new Platform(1400, 200, 200, 50));
    mPlatforms.push_back(new Platform(1600, 550, 200, 50));   // Sol droit
    
    mBlocks.push_back(new Block(250, 450, BlockType::QUESTION));
    mBlocks.push_back(new Block(450, 400, BlockType::QUESTION));
    mBlocks.push_back(new Block(850, 300, BlockType::QUESTION));
    
    mCoins.push_back(new Coin(300, 400));
    mCoins.push_back(new Coin(500, 350));
    mCoins.push_back(new Coin(900, 250));
    
    mEnemies.push_back(new Enemy(300, 470, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(500, 420, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(700, 370, EnemyType::GOOMBA));
    
    mCheckpoints.push_back(new Checkpoint(800, 300));
    mClouds.push_back(new Cloud(200, 50, 80, 40));
    mClouds.push_back(new Cloud(800, 60, 90, 45));
}

void Game::LoadLevel2() {
    // Niveau 2 - Koopa arrive
    mPlatforms.push_back(new Platform(0, 550, 150, 50));
    mPlatforms.push_back(new Platform(200, 480, 120, 50));
    mPlatforms.push_back(new Platform(380, 520, 100, 50));
    mPlatforms.push_back(new Platform(530, 450, 120, 50));
    mPlatforms.push_back(new Platform(700, 500, 100, 50));
    mPlatforms.push_back(new Platform(850, 400, 150, 50));
    mPlatforms.push_back(new Platform(1050, 350, 120, 50));
    mPlatforms.push_back(new Platform(1220, 450, 100, 50));
    mPlatforms.push_back(new Platform(1370, 300, 150, 50));
    mPlatforms.push_back(new Platform(1550, 400, 150, 50));
    mPlatforms.push_back(new Platform(1730, 250, 120, 50));
    mPlatforms.push_back(new Platform(1900, 550, 300, 50));
    
    mBlocks.push_back(new Block(230, 430, BlockType::QUESTION));
    mBlocks.push_back(new Block(560, 400, BlockType::BRICK));
    mBlocks.push_back(new Block(890, 350, BlockType::QUESTION));
    mBlocks.push_back(new Block(1090, 300, BlockType::BRICK));
    mBlocks.push_back(new Block(1410, 250, BlockType::QUESTION));
    
    mCoins.push_back(new Coin(250, 430));
    mCoins.push_back(new Coin(570, 400));
    mCoins.push_back(new Coin(600, 350));
    mCoins.push_back(new Coin(1100, 300));
    
    mEnemies.push_back(new Enemy(350, 430, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(550, 400, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(750, 450, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(1080, 300, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(1600, 350, EnemyType::KOOPA));
    
    mCheckpoints.push_back(new Checkpoint(1000, 300));
    mSpikes.push_back(new Spike(380, 530, 100, 20));
    mClouds.push_back(new Cloud(300, 50, 80, 40));
    mClouds.push_back(new Cloud(900, 70, 90, 45));
}

void Game::LoadLevel3() {
    // Niveau 3 - Plateformes mobiles
    mPlatforms.push_back(new Platform(0, 550, 150, 50));
    mPlatforms.push_back(new Platform(200, 480, 120, 50));
    mPlatforms.push_back(new Platform(380, 520, 100, 50, PlatformType::MOVING_H));
    mPlatforms.push_back(new Platform(530, 450, 120, 50));
    mPlatforms.push_back(new Platform(700, 400, 100, 50, PlatformType::MOVING_V));
    mPlatforms.push_back(new Platform(850, 450, 150, 50));
    mPlatforms.push_back(new Platform(1050, 350, 120, 50));
    mPlatforms.push_back(new Platform(1220, 400, 100, 50, PlatformType::MOVING_H));
    mPlatforms.push_back(new Platform(1370, 300, 150, 50));
    mPlatforms.push_back(new Platform(1550, 250, 120, 50));
    mPlatforms.push_back(new Platform(1730, 350, 100, 50, PlatformType::MOVING_V));
    mPlatforms.push_back(new Platform(1900, 300, 150, 50));
    mPlatforms.push_back(new Platform(2100, 550, 300, 50));
    
    mBlocks.push_back(new Block(560, 400, BlockType::QUESTION));
    mBlocks.push_back(new Block(890, 400, BlockType::BRICK));
    mBlocks.push_back(new Block(1410, 250, BlockType::QUESTION));
    
    mCoins.push_back(new Coin(600, 400));
    mCoins.push_back(new Coin(680, 350));
    mCoins.push_back(new Coin(900, 400));
    mCoins.push_back(new Coin(1100, 300));
    
    mEnemies.push_back(new Enemy(350, 430, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(750, 350, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(1080, 300, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(1600, 200, EnemyType::FLYING));
    
    mCheckpoints.push_back(new Checkpoint(1200, 350));
    mPowerUps.push_back(new PowerUp(600, 400, PowerUpType::MUSHROOM));
    mClouds.push_back(new Cloud(400, 50, 80, 40));
    mClouds.push_back(new Cloud(1200, 60, 90, 45));
}

void Game::LoadLevel4() {
    // Niveau 4 - Plus de défis
    mPlatforms.push_back(new Platform(0, 550, 150, 50));
    mPlatforms.push_back(new Platform(200, 500, 100, 50));
    mPlatforms.push_back(new Platform(350, 450, 120, 50));
    mPlatforms.push_back(new Platform(520, 520, 80, 50));
    mPlatforms.push_back(new Platform(650, 400, 100, 50));
    mPlatforms.push_back(new Platform(800, 480, 120, 50));
    mPlatforms.push_back(new Platform(970, 350, 100, 50));
    mPlatforms.push_back(new Platform(1120, 450, 120, 50));
    mPlatforms.push_back(new Platform(1290, 300, 100, 50));
    mPlatforms.push_back(new Platform(1440, 400, 120, 50));
    mPlatforms.push_back(new Platform(1610, 250, 150, 50));
    mPlatforms.push_back(new Platform(1810, 350, 100, 50));
    mPlatforms.push_back(new Platform(1960, 550, 300, 50));
    
    mBlocks.push_back(new Block(370, 400, BlockType::QUESTION));
    mBlocks.push_back(new Block(660, 350, BlockType::BRICK));
    mBlocks.push_back(new Block(990, 300, BlockType::QUESTION));
    mBlocks.push_back(new Block(1140, 400, BlockType::HARD));
    mBlocks.push_back(new Block(1310, 250, BlockType::QUESTION));
    
    mCoins.push_back(new Coin(380, 400));
    mCoins.push_back(new Coin(670, 350));
    mCoins.push_back(new Coin(690, 300));
    mCoins.push_back(new Coin(1000, 300));
    mCoins.push_back(new Coin(1320, 250));
    
    mEnemies.push_back(new Enemy(360, 400, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(520, 470, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(760, 430, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(1000, 300, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(1450, 350, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(1650, 200, EnemyType::KOOPA));
    
    mCheckpoints.push_back(new Checkpoint(1100, 400));
    mSpikes.push_back(new Spike(520, 530, 80, 20));
    mSpikes.push_back(new Spike(1120, 460, 80, 20));
    mClouds.push_back(new Cloud(500, 50, 80, 40));
    mClouds.push_back(new Cloud(1300, 70, 90, 45));
}

void Game::LoadLevel5() {
    // Niveau 5 - Boss intermédiaire
    mPlatforms.push_back(new Platform(0, 550, 150, 50));
    mPlatforms.push_back(new Platform(200, 480, 120, 50));
    mPlatforms.push_back(new Platform(380, 420, 100, 50));
    mPlatforms.push_back(new Platform(530, 480, 120, 50));
    mPlatforms.push_back(new Platform(700, 380, 150, 50));
    mPlatforms.push_back(new Platform(900, 450, 120, 50));
    mPlatforms.push_back(new Platform(1070, 320, 150, 50));
    mPlatforms.push_back(new Platform(1270, 400, 120, 50));
    mPlatforms.push_back(new Platform(1440, 280, 150, 50));
    mPlatforms.push_back(new Platform(1640, 380, 150, 50));
    mPlatforms.push_back(new Platform(1840, 240, 200, 50));  // Plateforme du boss
    mPlatforms.push_back(new Platform(2100, 550, 300, 50));
    
    mBlocks.push_back(new Block(410, 370, BlockType::QUESTION));
    mBlocks.push_back(new Block(730, 330, BlockType::BRICK));
    mBlocks.push_back(new Block(1100, 270, BlockType::QUESTION));
    mBlocks.push_back(new Block(1480, 230, BlockType::HARD));
    
    mCoins.push_back(new Coin(420, 370));
    mCoins.push_back(new Coin(740, 330));
    mCoins.push_back(new Coin(760, 280));
    mCoins.push_back(new Coin(1110, 270));
    
    mEnemies.push_back(new Enemy(400, 370, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(550, 430, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(760, 330, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(1080, 270, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(1280, 350, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(1920, 190, EnemyType::BOSS));  // Boss
    
    mCheckpoints.push_back(new Checkpoint(1400, 230));
    mPowerUps.push_back(new PowerUp(750, 330, PowerUpType::FEATHER));
    mClouds.push_back(new Cloud(600, 50, 80, 40));
    mClouds.push_back(new Cloud(1500, 60, 90, 45));
}

void Game::LoadLevel6() {
    // Niveau 6 - Tuyaux et téléportation
    mPlatforms.push_back(new Platform(0, 550, 150, 50));
    mPlatforms.push_back(new Platform(200, 500, 120, 50));
    mPlatforms.push_back(new Platform(380, 450, 100, 50));
    mPlatforms.push_back(new Platform(530, 500, 120, 50));
    mPlatforms.push_back(new Platform(700, 400, 150, 50));
    mPlatforms.push_back(new Platform(900, 480, 120, 50));
    mPlatforms.push_back(new Platform(1070, 350, 150, 50));
    mPlatforms.push_back(new Platform(1270, 420, 120, 50));
    mPlatforms.push_back(new Platform(1440, 300, 150, 50));
    mPlatforms.push_back(new Platform(1640, 380, 150, 50));
    mPlatforms.push_back(new Platform(1840, 260, 150, 50));
    mPlatforms.push_back(new Platform(2040, 340, 150, 50));
    mPlatforms.push_back(new Platform(2240, 550, 300, 50));
    
    mBlocks.push_back(new Block(410, 400, BlockType::QUESTION));
    mBlocks.push_back(new Block(730, 350, BlockType::BRICK));
    mBlocks.push_back(new Block(1100, 300, BlockType::QUESTION));
    mBlocks.push_back(new Block(1480, 250, BlockType::QUESTION));
    
    mCoins.push_back(new Coin(420, 400));
    mCoins.push_back(new Coin(600, 350));
    mCoins.push_back(new Coin(740, 350));
    mCoins.push_back(new Coin(1110, 300));
    
    mEnemies.push_back(new Enemy(400, 400, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(560, 450, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(760, 350, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(1080, 300, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(1280, 370, EnemyType::KOOPA));
    
    mPipes.push_back(new Pipe(750, 350, 40, 100, 1500, 250));
    mPipes.push_back(new Pipe(1600, 330, 40, 100, 1900, 210));
    
    mCheckpoints.push_back(new Checkpoint(1400, 250));
    mClouds.push_back(new Cloud(700, 50, 80, 40));
    mClouds.push_back(new Cloud(1700, 60, 90, 45));
}

void Game::LoadLevel7() {
    // Niveau 7 - Plateformes destructibles
    mPlatforms.push_back(new Platform(0, 550, 150, 50));
    mPlatforms.push_back(new Platform(200, 480, 120, 50));
    mPlatforms.push_back(new Platform(380, 420, 100, 50, PlatformType::DESTRUCTIBLE));
    mPlatforms.push_back(new Platform(530, 480, 120, 50));
    mPlatforms.push_back(new Platform(700, 380, 150, 50, PlatformType::DESTRUCTIBLE));
    mPlatforms.push_back(new Platform(900, 450, 120, 50));
    mPlatforms.push_back(new Platform(1070, 320, 150, 50));
    mPlatforms.push_back(new Platform(1270, 400, 120, 50, PlatformType::DESTRUCTIBLE));
    mPlatforms.push_back(new Platform(1440, 280, 150, 50));
    mPlatforms.push_back(new Platform(1640, 360, 150, 50));
    mPlatforms.push_back(new Platform(1840, 240, 150, 50));
    mPlatforms.push_back(new Platform(2040, 320, 150, 50));
    mPlatforms.push_back(new Platform(2240, 550, 300, 50));
    
    mBlocks.push_back(new Block(410, 370, BlockType::QUESTION));
    mBlocks.push_back(new Block(730, 330, BlockType::BRICK));
    mBlocks.push_back(new Block(1100, 270, BlockType::QUESTION));
    mBlocks.push_back(new Block(1480, 230, BlockType::HARD));
    
    mCoins.push_back(new Coin(420, 370));
    mCoins.push_back(new Coin(740, 330));
    mCoins.push_back(new Coin(1110, 270));
    mCoins.push_back(new Coin(1490, 230));
    
    mEnemies.push_back(new Enemy(400, 370, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(560, 430, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(1080, 270, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(1280, 350, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(1680, 310, EnemyType::KOOPA));
    
    mCheckpoints.push_back(new Checkpoint(1400, 230));
    mSpikes.push_back(new Spike(530, 490, 120, 20));
    mSpikes.push_back(new Spike(1270, 410, 120, 20));
    mClouds.push_back(new Cloud(800, 50, 80, 40));
    mClouds.push_back(new Cloud(1800, 60, 90, 45));
}

void Game::LoadLevel8() {
    // Niveau 8 - Mixte difficile
    mPlatforms.push_back(new Platform(0, 550, 150, 50));
    mPlatforms.push_back(new Platform(200, 500, 100, 50));
    mPlatforms.push_back(new Platform(350, 450, 120, 50, PlatformType::MOVING_H));
    mPlatforms.push_back(new Platform(520, 520, 80, 50));
    mPlatforms.push_back(new Platform(650, 400, 100, 50, PlatformType::MOVING_V));
    mPlatforms.push_back(new Platform(800, 480, 120, 50));
    mPlatforms.push_back(new Platform(970, 350, 100, 50, PlatformType::DESTRUCTIBLE));
    mPlatforms.push_back(new Platform(1120, 450, 120, 50));
    mPlatforms.push_back(new Platform(1290, 300, 100, 50, PlatformType::MOVING_H));
    mPlatforms.push_back(new Platform(1440, 400, 120, 50));
    mPlatforms.push_back(new Platform(1610, 250, 150, 50));
    mPlatforms.push_back(new Platform(1810, 350, 100, 50));
    mPlatforms.push_back(new Platform(2010, 280, 150, 50));
    mPlatforms.push_back(new Platform(2210, 550, 300, 50));
    
    mBlocks.push_back(new Block(370, 400, BlockType::QUESTION));
    mBlocks.push_back(new Block(660, 350, BlockType::BRICK));
    mBlocks.push_back(new Block(990, 300, BlockType::QUESTION));
    mBlocks.push_back(new Block(1310, 250, BlockType::HARD));
    
    mCoins.push_back(new Coin(380, 400));
    mCoins.push_back(new Coin(670, 350));
    mCoins.push_back(new Coin(1000, 300));
    mCoins.push_back(new Coin(1320, 250));
    
    mEnemies.push_back(new Enemy(360, 400, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(560, 450, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(780, 430, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(1000, 300, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(1160, 400, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(1650, 200, EnemyType::FLYING));
    
    mCheckpoints.push_back(new Checkpoint(1300, 250));
    mSpikes.push_back(new Spike(520, 530, 80, 20));
    mSpikes.push_back(new Spike(1120, 460, 80, 20));
    mClouds.push_back(new Cloud(900, 50, 80, 40));
    mClouds.push_back(new Cloud(1900, 70, 90, 45));
}

void Game::LoadLevel9() {
    // Niveau 9 - Avant dernier niveau
    mPlatforms.push_back(new Platform(0, 550, 150, 50));
    mPlatforms.push_back(new Platform(200, 480, 120, 50));
    mPlatforms.push_back(new Platform(380, 420, 100, 50));
    mPlatforms.push_back(new Platform(530, 480, 120, 50));
    mPlatforms.push_back(new Platform(700, 380, 150, 50, PlatformType::MOVING_H));
    mPlatforms.push_back(new Platform(900, 450, 120, 50));
    mPlatforms.push_back(new Platform(1070, 320, 150, 50));
    mPlatforms.push_back(new Platform(1270, 400, 120, 50, PlatformType::DESTRUCTIBLE));
    mPlatforms.push_back(new Platform(1440, 280, 150, 50));
    mPlatforms.push_back(new Platform(1640, 360, 150, 50, PlatformType::MOVING_V));
    mPlatforms.push_back(new Platform(1840, 240, 150, 50));
    mPlatforms.push_back(new Platform(2040, 320, 150, 50));
    mPlatforms.push_back(new Platform(2240, 200, 150, 50));
    mPlatforms.push_back(new Platform(2440, 550, 300, 50));
    
    mBlocks.push_back(new Block(410, 370, BlockType::QUESTION));
    mBlocks.push_back(new Block(730, 330, BlockType::BRICK));
    mBlocks.push_back(new Block(1100, 270, BlockType::QUESTION));
    mBlocks.push_back(new Block(1480, 230, BlockType::QUESTION));
    mBlocks.push_back(new Block(2280, 150, BlockType::HARD));
    
    mCoins.push_back(new Coin(420, 370));
    mCoins.push_back(new Coin(600, 330));
    mCoins.push_back(new Coin(740, 330));
    mCoins.push_back(new Coin(1110, 270));
    mCoins.push_back(new Coin(1490, 230));
    
    mEnemies.push_back(new Enemy(400, 370, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(560, 430, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(780, 330, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(1080, 270, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(1280, 350, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(1680, 310, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(2320, 150, EnemyType::BOSS));
    
    mCheckpoints.push_back(new Checkpoint(1400, 230));
    mCheckpoints.push_back(new Checkpoint(2200, 150));
    mSpikes.push_back(new Spike(530, 490, 120, 20));
    mSpikes.push_back(new Spike(1270, 410, 120, 20));
    mPowerUps.push_back(new PowerUp(1120, 270, PowerUpType::STAR));
    mClouds.push_back(new Cloud(1000, 50, 80, 40));
    mClouds.push_back(new Cloud(2000, 60, 90, 45));
}

void Game::LoadLevel10() {
    // Niveau 10 - Final avec grand boss
    mPlatforms.push_back(new Platform(0, 550, 150, 50));
    mPlatforms.push_back(new Platform(200, 500, 120, 50));
    mPlatforms.push_back(new Platform(380, 450, 100, 50));
    mPlatforms.push_back(new Platform(530, 480, 120, 50));
    mPlatforms.push_back(new Platform(700, 400, 150, 50, PlatformType::MOVING_H));
    mPlatforms.push_back(new Platform(900, 450, 120, 50));
    mPlatforms.push_back(new Platform(1070, 350, 150, 50));
    mPlatforms.push_back(new Platform(1270, 400, 120, 50));
    mPlatforms.push_back(new Platform(1440, 300, 150, 50, PlatformType::MOVING_V));
    mPlatforms.push_back(new Platform(1640, 380, 150, 50));
    mPlatforms.push_back(new Platform(1840, 260, 150, 50));
    mPlatforms.push_back(new Platform(2040, 340, 150, 50));
    mPlatforms.push_back(new Platform(2240, 220, 200, 50));
    mPlatforms.push_back(new Platform(2490, 300, 150, 50));
    mPlatforms.push_back(new Platform(2690, 380, 150, 50));
    mPlatforms.push_back(new Platform(2890, 260, 250, 50));  // Plateforme du boss final
    mPlatforms.push_back(new Platform(3200, 550, 800, 50));
    
    mBlocks.push_back(new Block(410, 400, BlockType::QUESTION));
    mBlocks.push_back(new Block(730, 350, BlockType::BRICK));
    mBlocks.push_back(new Block(1100, 300, BlockType::QUESTION));
    mBlocks.push_back(new Block(1480, 250, BlockType::QUESTION));
    mBlocks.push_back(new Block(2280, 170, BlockType::HARD));
    
    mCoins.push_back(new Coin(420, 400));
    mCoins.push_back(new Coin(600, 350));
    mCoins.push_back(new Coin(740, 350));
    mCoins.push_back(new Coin(1110, 300));
    mCoins.push_back(new Coin(1490, 250));
    mCoins.push_back(new Coin(2290, 170));
    
    mEnemies.push_back(new Enemy(400, 400, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(560, 430, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(780, 350, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(1080, 300, EnemyType::GOOMBA));
    mEnemies.push_back(new Enemy(1280, 350, EnemyType::KOOPA));
    mEnemies.push_back(new Enemy(1680, 330, EnemyType::FLYING));
    mEnemies.push_back(new Enemy(3040, 210, EnemyType::BOSS));  // Grand boss final
    
    mCheckpoints.push_back(new Checkpoint(1400, 250));
    mCheckpoints.push_back(new Checkpoint(2800, 210));
    mSpikes.push_back(new Spike(530, 490, 120, 20));
    mSpikes.push_back(new Spike(1270, 410, 120, 20));
    mSpikes.push_back(new Spike(2040, 350, 150, 20));
    mPowerUps.push_back(new PowerUp(1120, 300, PowerUpType::STAR));
    mPipes.push_back(new Pipe(1550, 330, 40, 100, 2300, 170));
    mClouds.push_back(new Cloud(1100, 50, 80, 40));
    mClouds.push_back(new Cloud(2500, 60, 90, 45));
}

void Game::LoadLevelExtra(int level) {
    // Niveaux supplémentaires (11+) - Génération procédurale basique
    float baseX = 0.0f;
    float spacing = 200.0f;
    
    // Sol de départ
    mPlatforms.push_back(new Platform(baseX, 550, 150, 50));
    baseX += 200;
    
    // Générer des plateformes aléatoires
    for (int i = 0; i < 15 + (level - 10); i++) {
        float height = 450.0f + (rand() % 150);
        float width = 100.0f + (rand() % 100);
        
        PlatformType type = PlatformType::STATIC;
        if (rand() % 4 == 0) {
            type = (rand() % 2 == 0) ? PlatformType::MOVING_H : PlatformType::MOVING_V;
        } else if (rand() % 5 == 0) {
            type = PlatformType::DESTRUCTIBLE;
        }
        
        mPlatforms.push_back(new Platform(baseX, height, width, 50, type));
        
        // Ajouter des blocs et pièces occasionnellement
        if (rand() % 3 == 0) {
            BlockType blockType = (rand() % 3 == 0) ? BlockType::QUESTION : BlockType::BRICK;
            mBlocks.push_back(new Block(baseX + 20, height - 50, blockType));
        }
        
        if (rand() % 2 == 0) {
            mCoins.push_back(new Coin(baseX + 30, height - 30));
        }
        
        // Ajouter des ennemis occasionnellement
        if (rand() % 3 == 0) {
            EnemyType enemyType = EnemyType::GOOMBA;
            int enemyRand = rand() % 10;
            if (enemyRand < 4) enemyType = EnemyType::GOOMBA;
            else if (enemyRand < 7) enemyType = EnemyType::KOOPA;
            else enemyType = EnemyType::FLYING;
            
            mEnemies.push_back(new Enemy(baseX + 40, height - 30, enemyType));
        }
        
        baseX += spacing + (rand() % 100);
    }
    
    // Sol de fin
    mPlatforms.push_back(new Platform(baseX, 550, 300, 50));
    
    // Boss tous les 5 niveaux supplémentaires
    if ((level - 10) % 5 == 0) {
        mEnemies.push_back(new Enemy(baseX - 100, 400, EnemyType::BOSS));
    }
    
    // Checkpoints
    mCheckpoints.push_back(new Checkpoint(baseX / 3, 400));
    mCheckpoints.push_back(new Checkpoint(baseX * 2 / 3, 300));
    
    mClouds.push_back(new Cloud(baseX / 4, 50, 80, 40));
    mClouds.push_back(new Cloud(baseX / 2, 60, 90, 45));
    mClouds.push_back(new Cloud(baseX * 3 / 4, 70, 85, 42));
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
        
        // Vérifier si la musique Level Clear est terminée et reprendre la musique de fond
        // Cette vérification doit se faire dans Run() pour fonctionner même quand on n'est pas en PLAYING
        if (mGameState == GameState::LEVEL_COMPLETE && mLevelClearMusic && mBackgroundMusic) {
            if (!Mix_PlayingMusic()) {
                // La musique Level Clear est terminée, reprendre la musique de fond
                if (Mix_PlayMusic(mBackgroundMusic, -1) == -1) {
                    std::cerr << "Impossible de reprendre la musique de fond: " << Mix_GetError() << std::endl;
                }
            }
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
            std::cout << "Fermeture du jeu..." << std::endl;
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
                        // Reprendre la musique de fond après le changement de niveau
                        if (mBackgroundMusic) {
                            Mix_HaltMusic();
                            if (Mix_PlayMusic(mBackgroundMusic, -1) == -1) {
                                std::cerr << "Impossible de reprendre la musique de fond: " << Mix_GetError() << std::endl;
                            }
                        }
                    } else {
                        // Reprendre au niveau actuel (ne pas revenir au niveau 1)
                        mLives = 3;
                        LoadLevel();
                        mGameState = GameState::PLAYING;
                        // Reprendre la musique de fond après le redémarrage
                        if (mBackgroundMusic) {
                            Mix_HaltMusic();
                            if (Mix_PlayMusic(mBackgroundMusic, -1) == -1) {
                                std::cerr << "Impossible de reprendre la musique de fond: " << Mix_GetError() << std::endl;
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (mGameState == GameState::PLAYING && !mPaused && mPlayer && mGameState != GameState::PAUSE_MENU) {
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
    
    // Mettre à jour le timer
    if (mLevelTimer > 0.0f) {
        mLevelTimer -= deltaTime;
        if (mLevelTimer <= 0.0f) {
            // Time's up!
            mLives--;
            if (mLives > 0) {
                if (mHasCheckpoint) {
                    mPlayer->Respawn(mCheckpointX, mCheckpointY);
                } else {
                    mPlayer->Respawn(100.0f, 100.0f);
                }
                mLevelTimer = 300.0f;  // Réinitialiser le timer
            } else {
                mPlayer->Kill();
                mGameState = GameState::GAME_OVER;
            }
        }
    }
    
    // Mettre à jour le joueur
    mPlayer->Update(deltaTime);
    mPlayer->UpdateShootCooldown(deltaTime);
    
    // Mettre à jour les plateformes (pour les mobiles)
    for (auto* platform : mPlatforms) {
        platform->Update(deltaTime);
    }
    
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
    
    // Mettre à jour les nuages
    for (auto* cloud : mClouds) {
        cloud->Update(deltaTime);
    }
    
    // Mettre à jour les particules
    for (auto it = mParticles.begin(); it != mParticles.end();) {
        it->x += it->vx * deltaTime;
        it->y += it->vy * deltaTime;
        it->life -= deltaTime;
        
        if (it->life <= 0.0f) {
            it = mParticles.erase(it);
        } else {
            ++it;
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
            if (mHasCheckpoint) {
                mPlayer->Respawn(mCheckpointX, mCheckpointY);
            } else {
                mPlayer->Respawn(100.0f, 100.0f);
            }
        } else {
            mPlayer->Kill();
            mGameState = GameState::GAME_OVER;
        }
    }
    
    // Vérifier si le niveau est complété
    if (mPlayer->GetX() >= mLevelEndX && mGameState != GameState::LEVEL_COMPLETE) {
        mGameState = GameState::LEVEL_COMPLETE;
        mScore += 1000 * mCurrentLevel; // Bonus pour compléter le niveau
        
        // Arrêter la musique de fond et jouer Level Clear
        if (mLevelClearMusic && mBackgroundMusic) {
            Mix_HaltMusic();
            if (Mix_PlayMusic(mLevelClearMusic, 0) == -1) {  // 0 = jouer une seule fois
                std::cerr << "Impossible de jouer la musique Level Clear: " << Mix_GetError() << std::endl;
            }
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
                int randVal = rand() % 7;
                if (randVal == 0) {
                    mPowerUps.push_back(new PowerUp(blockRect.x, blockRect.y - 30, PowerUpType::MUSHROOM));
                } else if (randVal == 1 && mPlayer->IsBig()) {
                    mPowerUps.push_back(new PowerUp(blockRect.x, blockRect.y - 30, PowerUpType::FIRE_FLOWER));
                } else if (randVal == 2) {
                    mPowerUps.push_back(new PowerUp(blockRect.x, blockRect.y - 30, PowerUpType::FEATHER));
                } else if (randVal == 3) {
                    mPowerUps.push_back(new PowerUp(blockRect.x, blockRect.y - 30, PowerUpType::STAR));
                } else if (randVal == 4) {
                    mPowerUps.push_back(new PowerUp(blockRect.x, blockRect.y - 30, PowerUpType::ONE_UP));
                } else if (randVal == 5) {
                    mPowerUps.push_back(new PowerUp(blockRect.x, blockRect.y - 30, PowerUpType::COMET));
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
            } else if (powerUp->GetType() == PowerUpType::FEATHER) {
                mPlayer->CollectFeather();
                mScore += 800;
            } else if (powerUp->GetType() == PowerUpType::STAR) {
                mPlayer->CollectStar();
                mScore += 1500;
            } else if (powerUp->GetType() == PowerUpType::ONE_UP) {
                mPlayer->CollectOneUp();
                mLives++;
                mScore += 2000;
            } else if (powerUp->GetType() == PowerUpType::COMET) {
                mPlayer->CollectComet();
                mScore += 1200;
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
        SDL_Color gameOverColor = {255, 0, 0, 255}; // Rouge
        RenderText("GAME OVER", 280, 200, gameOverColor, 48);
        
        // Afficher le score
        std::ostringstream scoreStream;
        scoreStream << "Score: " << mScore;
        SDL_Color scoreColor = {255, 255, 255, 255}; // Blanc
        RenderText(scoreStream.str().c_str(), 300, 280, scoreColor, 32);
        
        // Afficher "Appuyez sur Entree pour recommencer"
        SDL_Color instructionColor = {200, 200, 200, 255}; // Gris clair
        RenderText("Appuyez sur Entree pour recommencer", 180, 350, instructionColor, 24);
    } else if (mGameState == GameState::LEVEL_COMPLETE) {
        // Fond
        SDL_SetRenderDrawColor(mRenderer, 0, 50, 0, 255);
        SDL_RenderClear(mRenderer);
        
        // Afficher "LEVEL COMPLETE"
        SDL_Color completeColor = {0, 255, 0, 255}; // Vert
        RenderText("LEVEL COMPLETE!", 240, 180, completeColor, 48);
        
        // Afficher le score
        std::ostringstream scoreStream;
        scoreStream << "Score: " << mScore;
        SDL_Color scoreColor = {255, 255, 255, 255}; // Blanc
        RenderText(scoreStream.str().c_str(), 300, 250, scoreColor, 32);
        
        // Afficher le prochain niveau
        std::ostringstream nextLevelStream;
        nextLevelStream << "Prochain niveau: " << (mCurrentLevel + 1);
        SDL_Color nextLevelColor = {255, 255, 0, 255}; // Jaune
        RenderText(nextLevelStream.str().c_str(), 240, 300, nextLevelColor, 32);
        
        // Afficher "Appuyez sur Entree pour continuer"
        SDL_Color instructionColor = {200, 200, 200, 255}; // Gris clair
        RenderText("Appuyez sur Entree pour continuer", 180, 370, instructionColor, 24);
    }
    
    SDL_RenderPresent(mRenderer);
}

void Game::RenderText(const char* text, int x, int y, SDL_Color color, int fontSize) {
    // Charger la police avec la taille spécifiée
    TTF_Font* font = nullptr;
    
    // Essayer de charger une police avec la taille demandée
    font = TTF_OpenFont("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", fontSize);
    if (!font) {
        font = TTF_OpenFont("/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf", fontSize);
    }
    if (!font) {
        font = TTF_OpenFont("/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf", fontSize);
    }
    
    // Si aucune police n'a pu être chargée, utiliser mFont comme fallback
    if (!font) {
        if (!mFont) {
            return; // Pas de police disponible
        }
        font = mFont;
    }
    
    // Créer une surface avec le texte
    SDL_Surface* textSurface = TTF_RenderText_Solid(font, text, color);
    if (!textSurface) {
        if (font != mFont) {
            TTF_CloseFont(font);
        }
        return;
    }
    
    // Créer une texture à partir de la surface
    SDL_Texture* textTexture = SDL_CreateTextureFromSurface(mRenderer, textSurface);
    if (!textTexture) {
        SDL_FreeSurface(textSurface);
        if (font != mFont) {
            TTF_CloseFont(font);
        }
        return;
    }
    
    // Obtenir les dimensions du texte
    int textWidth = textSurface->w;
    int textHeight = textSurface->h;
    
    // Créer le rectangle de destination
    SDL_Rect destRect = {x, y, textWidth, textHeight};
    
    // Rendre le texte
    SDL_RenderCopy(mRenderer, textTexture, nullptr, &destRect);
    
    // Nettoyer
    SDL_DestroyTexture(textTexture);
    SDL_FreeSurface(textSurface);
    if (font != mFont) {
        TTF_CloseFont(font);
    }
}

void Game::RenderUI() {
    // Barre d'information en haut
    SDL_SetRenderDrawColor(mRenderer, 0, 0, 0, 200);
    SDL_Rect uiRect = {0, 0, 800, 50};
    SDL_RenderFillRect(mRenderer, &uiRect);
    
    // Bordure
    SDL_SetRenderDrawColor(mRenderer, 255, 255, 255, 255);
    SDL_RenderDrawLine(mRenderer, 0, 50, 800, 50);
    
    // Afficher le score en texte
    std::ostringstream scoreStream;
    scoreStream << "Score: " << mScore;
    SDL_Color scoreColor = {255, 255, 0, 255}; // Jaune
    RenderText(scoreStream.str().c_str(), 10, 15, scoreColor);
    
    // Afficher les vies en texte
    std::ostringstream livesStream;
    livesStream << "Vies: " << mLives;
    SDL_Color livesColor = {255, 0, 0, 255}; // Rouge
    RenderText(livesStream.str().c_str(), 200, 15, livesColor);
    
    // Afficher les pièces en texte
    std::ostringstream coinsStream;
    coinsStream << "Pieces: " << mCoinsCollected;
    SDL_Color coinsColor = {255, 215, 0, 255}; // Or
    RenderText(coinsStream.str().c_str(), 320, 15, coinsColor);
    
    // Afficher le niveau en texte
    std::ostringstream levelStream;
    levelStream << "Niveau: " << mCurrentLevel;
    SDL_Color levelColor = {0, 255, 0, 255}; // Vert
    RenderText(levelStream.str().c_str(), 500, 15, levelColor);
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

void Game::LoadHighScores() {
    mHighScores.clear();
    std::ifstream file("highscores.dat", std::ios::binary);
    if (!file.is_open()) {
        // Fichier n'existe pas, créer des scores par défaut vides
        return;
    }
    
    int count = 0;
    file.read(reinterpret_cast<char*>(&count), sizeof(int));
    
    for (int i = 0; i < count && i < MAX_HIGH_SCORES; i++) {
        HighScore hs;
        int nameLen = 0;
        file.read(reinterpret_cast<char*>(&nameLen), sizeof(int));
        if (nameLen > 0 && nameLen < 100) {
            hs.name.resize(nameLen);
            file.read(&hs.name[0], nameLen);
        }
        file.read(reinterpret_cast<char*>(&hs.score), sizeof(int));
        file.read(reinterpret_cast<char*>(&hs.level), sizeof(int));
        int diff;
        file.read(reinterpret_cast<char*>(&diff), sizeof(int));
        hs.difficulty = static_cast<Difficulty>(diff);
        mHighScores.push_back(hs);
    }
    
    file.close();
}

void Game::SaveHighScores() {
    std::ofstream file("highscores.dat", std::ios::binary);
    if (!file.is_open()) {
        std::cerr << "Impossible d'ouvrir highscores.dat pour l'écriture" << std::endl;
        return;
    }
    
    int count = mHighScores.size();
    file.write(reinterpret_cast<const char*>(&count), sizeof(int));
    
    for (const auto& hs : mHighScores) {
        int nameLen = hs.name.length();
        file.write(reinterpret_cast<const char*>(&nameLen), sizeof(int));
        if (nameLen > 0) {
            file.write(hs.name.c_str(), nameLen);
        }
        file.write(reinterpret_cast<const char*>(&hs.score), sizeof(int));
        file.write(reinterpret_cast<const char*>(&hs.level), sizeof(int));
        int diff = static_cast<int>(hs.difficulty);
        file.write(reinterpret_cast<const char*>(&diff), sizeof(int));
    }
    
    file.close();
}

bool Game::CheckAndAddHighScore(int score) {
    // Vérifier si le score est suffisamment élevé
    if (mHighScores.size() < MAX_HIGH_SCORES || score > mHighScores.back().score) {
        // Demander le nom du joueur
        mWaitingForName = true;
        mPlayerName = "";
        mPlayerNameCursorPos = 0;
        mGameState = GameState::ENTER_NAME;
        return true;
    }
    return false;
}

void Game::Shutdown() {
    SaveHighScores();
    ResetLevel();
    
    if (mRenderer) {
        SDL_DestroyRenderer(mRenderer);
        mRenderer = nullptr;
    }
    
    if (mWindow) {
        SDL_DestroyWindow(mWindow);
        mWindow = nullptr;
    }
    
    if (mFont) {
        TTF_CloseFont(mFont);
        mFont = nullptr;
    }
        // Arrêter et libérer la musique
    if (mBackgroundMusic) {
        Mix_HaltMusic();
        Mix_FreeMusic(mBackgroundMusic);
        mBackgroundMusic = nullptr;
    }
    
    if (mLevelClearMusic) {
        Mix_FreeMusic(mLevelClearMusic);
        mLevelClearMusic = nullptr;
    }

    Mix_CloseAudio();
    TTF_Quit();
    IMG_Quit();
    SDL_Quit();
}
