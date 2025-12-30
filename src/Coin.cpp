#include "Coin.h"
#include <cmath>

const float Coin::BOUNCE_SPEED = 3.0f;
const float Coin::BOUNCE_HEIGHT = 10.0f;

Coin::Coin(float x, float y) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = 20.0f;
    mRect.h = 20.0f;
    mCollected = false;
    mAnimationTime = 0.0f;
    mOriginalY = y;
}

void Coin::Update(float deltaTime) {
    if (mCollected) return;
    
    mAnimationTime += deltaTime * BOUNCE_SPEED;
    mRect.y = mOriginalY + sin(mAnimationTime) * BOUNCE_HEIGHT;
}

void Coin::Render(SDL_Renderer* renderer, float cameraX) {
    if (mCollected) return;
    
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Dessiner la pièce en jaune/or
    SDL_SetRenderDrawColor(renderer, 255, 215, 0, 255);
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Bordure
    SDL_SetRenderDrawColor(renderer, 255, 200, 0, 255);
    SDL_RenderDrawRectF(renderer, &renderRect);
    
    // Symbole $
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    SDL_FRect symbol = {renderRect.x + 6, renderRect.y + 4, 8, 12};
    SDL_RenderDrawRectF(renderer, &symbol);
}

