#ifndef GAME_H
#define GAME_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <vector>
#include <string>
#include "Player.h"
#include "Platform.h"
#include "Enemy.h"
#include "Coin.h"
#include "PowerUp.h"
#include "Block.h"
#include "Fireball.h"

enum class GameState {
    MENU,
    PLAYING,
    PAUSED,
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
    void ResetLevel();
    
    SDL_Window* mWindow;
    SDL_Renderer* mRenderer;
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
    
    int mScore;
    int mLives;
    int mCoinsCollected;
    float mCameraX;
    float mLevelEndX;
    int mCurrentLevel;
    
    Uint32 mLastFrameTime;
};

#endif

