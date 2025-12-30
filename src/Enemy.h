#ifndef ENEMY_H
#define ENEMY_H

#include <SDL2/SDL.h>

class Enemy {
public:
    Enemy(float x, float y);
    
    void Update(float deltaTime);
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    
    bool IsDead() const { return mDead; }
    void Kill() { mDead = true; }
    
private:
    SDL_FRect mRect;
    float mVelocityX;
    bool mDead;
    float mStartX;
    float mPatrolDistance;
    
    static const float SPEED;
    static const float PATROL_RANGE;
};

#endif

