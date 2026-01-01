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
    } else {
        mVelocityY = 0;
    }
    
    // Mettre à jour la position
    mRect.x += mVelocityX * deltaTime;
    mRect.y += mVelocityY * deltaTime;
    
    mAnimationTime += deltaTime * 5.0f;
}

void PowerUp::SetPosition(float x, float y) {
    mRect.x = x;
    mRect.y = y;
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
    } else if (mType == PowerUpType::FEATHER) {
        // Plume - blanc/bleu clair pour représenter une plume
        SDL_SetRenderDrawColor(renderer, 240, 240, 255, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Tige de la plume (bleu)
        SDL_SetRenderDrawColor(renderer, 100, 150, 255, 255);
        SDL_FRect stem = {renderRect.x + 10, renderRect.y + 4, 4, renderRect.h - 8};
        SDL_RenderFillRectF(renderer, &stem);
        
        // Poils de la plume (lignes blanches)
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect feather1 = {renderRect.x + 2, renderRect.y + 6, 8, 2};
        SDL_FRect feather2 = {renderRect.x + 4, renderRect.y + 10, 10, 2};
        SDL_FRect feather3 = {renderRect.x + 2, renderRect.y + 14, 8, 2};
        SDL_RenderFillRectF(renderer, &feather1);
        SDL_RenderFillRectF(renderer, &feather2);
        SDL_RenderFillRectF(renderer, &feather3);
    } else if (mType == PowerUpType::STAR) {
        // Étoile invincible - jaune avec points
        SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Points de l'étoile (croix)
        SDL_SetRenderDrawColor(renderer, 255, 200, 0, 255);
        SDL_FRect star1 = {renderRect.x + 10, renderRect.y + 2, 4, renderRect.h - 4};
        SDL_FRect star2 = {renderRect.x + 2, renderRect.y + 10, renderRect.w - 4, 4};
        SDL_RenderFillRectF(renderer, &star1);
        SDL_RenderFillRectF(renderer, &star2);
    } else if (mType == PowerUpType::ONE_UP) {
        // 1-UP - vert avec "1"
        SDL_SetRenderDrawColor(renderer, 0, 200, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Chiffre "1" blanc
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect one1 = {renderRect.x + 10, renderRect.y + 4, 4, renderRect.h - 8};
        SDL_RenderFillRectF(renderer, &one1);
    } else if (mType == PowerUpType::COMET) {
        // Étoile filante - bleu/cyan avec traînée
        SDL_SetRenderDrawColor(renderer, 100, 200, 255, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Centre blanc
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        SDL_FRect center = {renderRect.x + 8, renderRect.y + 8, 8, 8};
        SDL_RenderFillRectF(renderer, &center);
        
        // Traînée (ligne)
        SDL_SetRenderDrawColor(renderer, 200, 240, 255, 255);
        SDL_FRect trail = {renderRect.x - 4, renderRect.y + 10, 4, 4};
        SDL_RenderFillRectF(renderer, &trail);
    }
}

