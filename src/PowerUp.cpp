#include "PowerUp.h"
#include <cmath>

const float PowerUp::GRAVITY = 400.0f;
const float PowerUp::SPEED = 50.0f;

PowerUp::PowerUp(float x, float y, PowerUpType type) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = 24.0f;
    mRect.h = 24.0f;
    mType = type;
    mCollected = false;
    mVelocityX = SPEED;
    mVelocityY = 0.0f;
    mOnGround = false;
    mAnimationTime = 0.0f;
}

void PowerUp::Update(float deltaTime) {
    if (mCollected) return;
    
    // Appliquer la gravité
    if (!mOnGround) {
        mVelocityY += GRAVITY * deltaTime;
    }
    
    // Mettre à jour la position
    mRect.x += mVelocityX * deltaTime;
    mRect.y += mVelocityY * deltaTime;
    
    mAnimationTime += deltaTime * 5.0f;
}

void PowerUp::Render(SDL_Renderer* renderer, float cameraX) {
    if (mCollected) return;
    
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    if (mType == PowerUpType::MUSHROOM) {
        // Champignon rouge avec points blancs
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Points blancs
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect dot1 = {renderRect.x + 4, renderRect.y + 4, 4, 4};
        SDL_FRect dot2 = {renderRect.x + 16, renderRect.y + 6, 4, 4};
        SDL_RenderFillRectF(renderer, &dot1);
        SDL_RenderFillRectF(renderer, &dot2);
    } else if (mType == PowerUpType::FIRE_FLOWER) {
        // Fleur de feu - rouge avec centre jaune
        SDL_SetRenderDrawColor(renderer, 255, 100, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Centre jaune
        SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);
        SDL_FRect center = {renderRect.x + 6, renderRect.y + 6, 12, 12};
        SDL_RenderFillRectF(renderer, &center);
    }
}

