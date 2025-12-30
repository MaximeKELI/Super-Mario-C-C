#include "Platform.h"

Platform::Platform(float x, float y, float width, float height) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = width;
    mRect.h = height;
}

void Platform::Render(SDL_Renderer* renderer, float cameraX) {
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Dessiner la plateforme en brun
    SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255);
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Bordure
    SDL_SetRenderDrawColor(renderer, 101, 67, 33, 255);
    SDL_RenderDrawRectF(renderer, &renderRect);
}


