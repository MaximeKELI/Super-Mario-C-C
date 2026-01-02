#ifndef GAME_H
#define GAME_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL_mixer.h>
#include <vector>
#include <string>
#include <sstream>
#include <fstream>
#include <algorithm>
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
    LEVEL_COMPLETE,
    HIGH_SCORES,
    STATISTICS,
    ENTER_NAME
};

enum class Difficulty {
    EASY,
    NORMAL,
    HARD
};

struct HighScore {
    std::string name;
    int score;
    int level;
    Difficulty difficulty;
    
    HighScore() : name(""), score(0), level(1), difficulty(Difficulty::NORMAL) {}
    HighScore(const std::string& n, int s, int l, Difficulty d) : name(n), score(s), level(l), difficulty(d) {}
};

struct GameStats {
    float totalPlayTime;
    int enemiesKilled;
    int powerUpsCollected;
    float distanceTraveled;
    int totalCoinsCollected;
    int levelsCompleted;
    
    GameStats() : totalPlayTime(0.0f), enemiesKilled(0), powerUpsCollected(0), 
                  distanceTraveled(0.0f), totalCoinsCollected(0), levelsCompleted(0) {}
};

struct SaveData {
    int currentLevel;
    int score;
    int lives;
    int coinsCollected;
    float checkpointX;
    float checkpointY;
    bool hasCheckpoint;
    Difficulty difficulty;
    GameStats stats;
    
    SaveData() : currentLevel(1), score(0), lives(3), coinsCollected(0),
                 checkpointX(100.0f), checkpointY(100.0f), hasCheckpoint(false),
                 difficulty(Difficulty::NORMAL) {}
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
    void RenderHighScores();
    void RenderStatistics();
    void RenderPauseMenu();
    void RenderMiniMap();
    void RenderEnterName();
    void LoadLevel();
    void LoadHighScores();
    void SaveHighScores();
    bool CheckAndAddHighScore(int score);
    void SaveGame();
    bool LoadGame();
    void ApplyDifficulty();
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
    
    // High Scores
    std::vector<HighScore> mHighScores;
    static const int MAX_HIGH_SCORES = 10;
    
    // Statistics
    GameStats mStats;
    float mLevelStartTime;
    float mLastPlayerX; // Pour calculer la distance
    
    // Difficulty
    Difficulty mDifficulty;
    
    // Pause menu
    int mPauseMenuSelection;
    int mPauseMenuMaxItems;
    bool mInOptionsMenu;
    int mOptionsMenuSelection;
    
    // Options
    int mMusicVolume;
    int mSoundVolume;
    
    // Enter name for high score
    std::string mPlayerName;
    int mPlayerNameCursorPos;
    bool mWaitingForName;
    
    Uint32 mLastFrameTime;
};

#endif

