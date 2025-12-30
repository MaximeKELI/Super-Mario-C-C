#ifndef ENEMY_H
#define ENEMY_H

#include <SDL2/SDL.h>

enum class EnemyType {
    GOOMBA,    // Goomba simple
    KOOPA,     // Koopa (tortue)
    FLYING     // Ennemi volant
};

class Enemy {
public:
    Enemy(float x, float y, EnemyType type = EnemyType::GOOMBA);
    
    void Update(float deltaTime);
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    
    bool IsDead() const { return mDead; }
    void Kill() { mDead = true; }
    EnemyType GetType() const { return mType; }
    
private:
    SDL_FRect mRect;
    float mVelocityX;
    float mVelocityY;
    bool mDead;
    float mStartX;
    float mPatrolDistance;
    EnemyType mType;
    float mFlyingTime;
    float mOriginalY;
    
    static const float SPEED;
    static const float PATROL_RANGE;
    static const float FLYING_SPEED;
    static const float FLYING_HEIGHT;
};

#endif

