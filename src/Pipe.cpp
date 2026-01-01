#include "Pipe.h"

Pipe::Pipe(float x, float y, float width, float height, float targetX, float targetY) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = width;
    mRect.h = height;
    mTargetX = targetX;
    mTargetY = targetY;
}

void Pipe::Render(SDL_Renderer* renderer, float cameraX) {
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Tuyau vert (style Mario)
    SDL_SetRenderDrawColor(renderer, 0, 180, 0, 255);
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Bordure sombre
    SDL_SetRenderDrawColor(renderer, 0, 120, 0, 255);
    SDL_RenderDrawRectF(renderer, &renderRect);
    
    // Lignes horizontales pour l'effet de tuyau
    SDL_SetRenderDrawColor(renderer, 0, 220, 0, 255);
    SDL_FRect line1 = {renderRect.x, renderRect.y + 4, renderRect.w, 2};
    SDL_FRect line2 = {renderRect.x, renderRect.y + renderRect.h - 6, renderRect.w, 2};
    SDL_RenderFillRectF(renderer, &line1);
    SDL_RenderFillRectF(renderer, &line2);
}

