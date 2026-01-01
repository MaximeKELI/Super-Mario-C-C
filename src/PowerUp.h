#ifndef POWERUP_H
#define POWERUP_H

#include <SDL2/SDL.h>

enum class PowerUpType {
    MUSHROOM,  // Champignon - grandit Mario
    FIRE_FLOWER,  // Fleur de feu - permet de lancer des boules de feu
    FEATHER  // Plume - permet à Mario de voler
};

class PowerUp {
public:
    PowerUp(float x, float y, PowerUpType type);
    
    void Update(float deltaTime);
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    void SetPosition(float x, float y);
    void SetOnGround(bool onGround) { mOnGround = onGround; }
    
    bool IsCollected() const { return mCollected; }
    void Collect() { mCollected = true; }
    PowerUpType GetType() const { return mType; }
    
private:
    SDL_FRect mRect;
    PowerUpType mType;
    bool mCollected;
    float mVelocityX;
    float mVelocityY;
    bool mOnGround;
    float mAnimationTime;
    
    static const float GRAVITY;
    static const float SPEED;
};

#endif

