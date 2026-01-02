#ifndef GAME_H
#define GAME_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL_mixer.h>
#include <vector>
#include <string>
#include <sstream>
#include "Player.h"
#include "Platform.h"
#include "Enemy.h"
#include "Coin.h"
#include "PowerUp.h"
#include "Block.h"
#include "Fireball.h"
#include "Spike.h"
#include "Cloud.h"
#include "Checkpoint.h"
#include "Pipe.h"
#include "Particle.h"
#include <vector>

enum class GameState {
    MENU,
    PLAYING,
    PAUSED,
    PAUSE_MENU,
    GAME_OVER,
    LEVEL_COMPLETE
};

class Game {
public:
    Game();
    ~Game();
    
    bool Initialize();
    void Run();
    void Shutdown();
    
private:
    void ProcessInput();
    void Update(float deltaTime);
    void Render();
    void CheckCollisions();
    void RenderUI();
    void RenderMenu();
    void LoadLevel();
    void LoadLevel1();
    void LoadLevel2();
    void LoadLevel3();
    void LoadLevel4();
    void LoadLevel5();
    void LoadLevel6();
    void LoadLevel7();
    void LoadLevel8();
    void LoadLevel9();
    void LoadLevel10();
    void LoadLevelExtra(int level);
    void ResetLevel();
    void RenderText(const char* text, int x, int y, SDL_Color color, int fontSize = 20);
    
    SDL_Window* mWindow;
    SDL_Renderer* mRenderer;
    TTF_Font* mFont;
    Mix_Music* mBackgroundMusic;
    Mix_Music* mLevelClearMusic;
    bool mIsRunning;
    GameState mGameState;
    bool mPaused;
    
    Player* mPlayer;
    std::vector<Platform*> mPlatforms;
    std::vector<Enemy*> mEnemies;
    std::vector<Coin*> mCoins;
    std::vector<PowerUp*> mPowerUps;
    std::vector<Block*> mBlocks;
    std::vector<Fireball*> mFireballs;
    std::vector<Spike*> mSpikes;
    std::vector<Cloud*> mClouds;
    std::vector<Checkpoint*> mCheckpoints;
    std::vector<Pipe*> mPipes;
    std::vector<Particle> mParticles;
    
    int mScore;
    int mLives;
    int mCoinsCollected;
    float mCameraX;
    float mLevelEndX;
    int mCurrentLevel;
    float mLevelTimer;
    float mCheckpointX;
    float mCheckpointY;
    bool mHasCheckpoint;
    
    Uint32 mLastFrameTime;
};

#endif

