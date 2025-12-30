#include "Fireball.h"

const float Fireball::SPEED = 300.0f;
const float Fireball::GRAVITY = 400.0f;

Fireball::Fireball(float x, float y, bool directionRight) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = 16.0f;
    mRect.h = 16.0f;
    mVelocityX = directionRight ? SPEED : -SPEED;
    mVelocityY = 0.0f;
    mDead = false;
    mAnimationTime = 0.0f;
}

void Fireball::Update(float deltaTime) {
    if (mDead) return;
    
    // Appliquer la gravité
    mVelocityY += GRAVITY * deltaTime;
    
    // Mettre à jour la position
    mRect.x += mVelocityX * deltaTime;
    mRect.y += mVelocityY * deltaTime;
    
    // Supprimer si hors écran
    if (mRect.y > 600 || mRect.x < -100 || mRect.x > 3000) {
        mDead = true;
    }
    
    mAnimationTime += deltaTime * 10.0f;
}

void Fireball::Render(SDL_Renderer* renderer, float cameraX) {
    if (mDead) return;
    
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Dessiner la boule de feu - rouge/orange
    SDL_SetRenderDrawColor(renderer, 255, 100, 0, 255);
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Centre plus clair
    SDL_SetRenderDrawColor(renderer, 255, 200, 0, 255);
    SDL_FRect center = {renderRect.x + 4, renderRect.y + 4, 8, 8};
    SDL_RenderFillRectF(renderer, &center);
}


