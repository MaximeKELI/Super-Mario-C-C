#ifndef FIREBALL_H
#define FIREBALL_H

#include <SDL2/SDL.h>

class Fireball {
public:
    Fireball(float x, float y, bool directionRight);
    
    void Update(float deltaTime);
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    
    bool IsDead() const { return mDead; }
    void Kill() { mDead = true; }
    
private:
    SDL_FRect mRect;
    float mVelocityX;
    float mVelocityY;
    bool mDead;
    float mAnimationTime;
    
    static const float SPEED;
    static const float GRAVITY;
};

#endif

