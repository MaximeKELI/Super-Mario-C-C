#include "Enemy.h"
#include <algorithm>

const float Enemy::SPEED = 50.0f;
const float Enemy::PATROL_RANGE = 150.0f;

Enemy::Enemy(float x, float y) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = 28.0f;
    mRect.h = 28.0f;
    mVelocityX = -SPEED;
    mDead = false;
    mStartX = x;
    mPatrolDistance = 0.0f;
}

void Enemy::Update(float deltaTime) {
    if (mDead) return;
    
    // Mouvement de patrouille
    mRect.x += mVelocityX * deltaTime;
    mPatrolDistance += abs(mVelocityX * deltaTime);
    
    // Inverser la direction si on dépasse la portée
    if (mPatrolDistance >= PATROL_RANGE) {
        mVelocityX = -mVelocityX;
        mPatrolDistance = 0.0f;
    }
}

void Enemy::Render(SDL_Renderer* renderer, float cameraX) {
    if (mDead) return;
    
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Dessiner l'ennemi en vert (Goomba)
    SDL_SetRenderDrawColor(renderer, 0, 150, 0, 255);
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Dessiner les yeux
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    SDL_FRect eye1 = {renderRect.x + 6, renderRect.y + 6, 4, 4};
    SDL_FRect eye2 = {renderRect.x + 18, renderRect.y + 6, 4, 4};
    SDL_RenderFillRectF(renderer, &eye1);
    SDL_RenderFillRectF(renderer, &eye2);
}

