#include "Enemy.h"
#include <algorithm>
#include <cmath>

const float Enemy::SPEED = 50.0f;
const float Enemy::PATROL_RANGE = 150.0f;
const float Enemy::FLYING_SPEED = 2.0f;
const float Enemy::FLYING_HEIGHT = 30.0f;

Enemy::Enemy(float x, float y, EnemyType type) {
    mRect.x = x;
    mRect.y = y;
    mType = type;
    
    if (mType == EnemyType::FLYING) {
        mRect.w = 24.0f;
        mRect.h = 24.0f;
        mOriginalY = y;
        mFlyingTime = 0.0f;
    } else if (mType == EnemyType::BOSS) {
        mRect.w = 64.0f;  // Boss plus grand
        mRect.h = 64.0f;
    } else {
        mRect.w = 28.0f;
        mRect.h = 28.0f;
    }
    
    mVelocityX = -SPEED;
    mVelocityY = 0.0f;
    mDead = false;
    mHealth = (type == EnemyType::BOSS) ? 5 : 1;  // Le boss a 5 vies
    mStartX = x;
    mPatrolDistance = 0.0f;
}

void Enemy::Update(float deltaTime) {
    if (mDead) return;
    
    if (mType == EnemyType::FLYING) {
        // Ennemi volant - mouvement sinusoïdal
        mFlyingTime += deltaTime * FLYING_SPEED;
        mRect.y = mOriginalY + sin(mFlyingTime) * FLYING_HEIGHT;
    } else if (mType == EnemyType::BOSS) {
        // Boss - mouvement plus lent et plus grand
        mVelocityX = -SPEED * 0.5f;  // Plus lent que les autres
    }
    
    // Mouvement de patrouille
    mRect.x += mVelocityX * deltaTime;
    mPatrolDistance += abs(mVelocityX * deltaTime);
    
    // Inverser la direction si on dépasse la portée
    float range = (mType == EnemyType::BOSS) ? PATROL_RANGE * 2.0f : PATROL_RANGE;
    if (mPatrolDistance >= range) {
        mVelocityX = -mVelocityX;
        mPatrolDistance = 0.0f;
    }
}

void Enemy::Render(SDL_Renderer* renderer, float cameraX) {
    if (mDead) return;
    
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    if (mType == EnemyType::GOOMBA) {
        // Goomba - marron
        SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Yeux
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect eye1 = {renderRect.x + 6, renderRect.y + 6, 4, 4};
        SDL_FRect eye2 = {renderRect.x + 18, renderRect.y + 6, 4, 4};
        SDL_RenderFillRectF(renderer, &eye1);
        SDL_RenderFillRectF(renderer, &eye2);
    } else if (mType == EnemyType::KOOPA) {
        // Koopa - vert avec carapace
        SDL_SetRenderDrawColor(renderer, 0, 150, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Carapace
        SDL_SetRenderDrawColor(renderer, 0, 200, 0, 255);
        SDL_FRect shell = {renderRect.x + 4, renderRect.y + 4, renderRect.w - 8, renderRect.h - 8};
        SDL_RenderFillRectF(renderer, &shell);
        
        // Yeux
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect eye1 = {renderRect.x + 6, renderRect.y + 8, 4, 4};
        SDL_FRect eye2 = {renderRect.x + 18, renderRect.y + 8, 4, 4};
        SDL_RenderFillRectF(renderer, &eye1);
        SDL_RenderFillRectF(renderer, &eye2);
    } else if (mType == EnemyType::FLYING) {
        // Ennemi volant - bleu
        SDL_SetRenderDrawColor(renderer, 0, 100, 200, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Ailes
        SDL_SetRenderDrawColor(renderer, 0, 150, 255, 255);
        SDL_FRect wing1 = {renderRect.x - 4, renderRect.y + 4, 8, 8};
        SDL_FRect wing2 = {renderRect.x + renderRect.w - 4, renderRect.y + 4, 8, 8};
        SDL_RenderFillRectF(renderer, &wing1);
        SDL_RenderFillRectF(renderer, &wing2);
        
        // Yeux
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect eye1 = {renderRect.x + 4, renderRect.y + 6, 4, 4};
        SDL_FRect eye2 = {renderRect.x + 16, renderRect.y + 6, 4, 4};
        SDL_RenderFillRectF(renderer, &eye1);
        SDL_RenderFillRectF(renderer, &eye2);
    } else if (mType == EnemyType::BOSS) {
        // Boss - grand et rouge/orange
        SDL_SetRenderDrawColor(renderer, 200, 50, 50, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Yeux rouges brillants
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        SDL_FRect eye1 = {renderRect.x + 12, renderRect.y + 12, 12, 12};
        SDL_FRect eye2 = {renderRect.x + 40, renderRect.y + 12, 12, 12};
        SDL_RenderFillRectF(renderer, &eye1);
        SDL_RenderFillRectF(renderer, &eye2);
        
        // Bordure sombre
        SDL_SetRenderDrawColor(renderer, 150, 0, 0, 255);
        SDL_RenderDrawRectF(renderer, &renderRect);
        
        // Couronne/casque
        SDL_SetRenderDrawColor(renderer, 255, 215, 0, 255);
        SDL_FRect crown = {renderRect.x + 8, renderRect.y - 8, renderRect.w - 16, 8};
        SDL_RenderFillRectF(renderer, &crown);
    }
}

