#include "Checkpoint.h"
#include <cmath>

Checkpoint::Checkpoint(float x, float y) : mAnimationTime(0.0f) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = 32.0f;
    mRect.h = 48.0f;
    mActivated = false;
    mAnimationTime = 0.0f;
}

void Checkpoint::Render(SDL_Renderer* renderer, float cameraX) {
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Animation de clignotement
    mAnimationTime += 0.1f;
    float alpha = (sin(mAnimationTime) + 1.0f) * 0.5f;  // Entre 0 et 1
    
    if (mActivated) {
        // Checkpoint activé - vert
        SDL_SetRenderDrawColor(renderer, 0, static_cast<Uint8>(255 * alpha), 0, 255);
    } else {
        // Checkpoint non activé - gris
        SDL_SetRenderDrawColor(renderer, static_cast<Uint8>(128 * alpha), static_cast<Uint8>(128 * alpha), static_cast<Uint8>(128 * alpha), 255);
    }
    
    // Poteau du checkpoint
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Drapeau en haut (si activé)
    if (mActivated) {
        SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);
        SDL_FRect flag = {renderRect.x + 16, renderRect.y - 16, 16, 16};
        SDL_RenderFillRectF(renderer, &flag);
    }
}

