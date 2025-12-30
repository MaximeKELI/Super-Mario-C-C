#ifndef GAME_H
#define GAME_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <vector>
#include "Player.h"
#include "Platform.h"
#include "Enemy.h"

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
    
    SDL_Window* mWindow;
    SDL_Renderer* mRenderer;
    bool mIsRunning;
    
    Player* mPlayer;
    std::vector<Platform*> mPlatforms;
    std::vector<Enemy*> mEnemies;
    
    int mScore;
    int mLives;
    float mCameraX;
    
    Uint32 mLastFrameTime;
};

#endif

