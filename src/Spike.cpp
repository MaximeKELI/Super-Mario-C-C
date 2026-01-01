#include "Spike.h"

Spike::Spike(float x, float y, float width, float height) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = width;
    mRect.h = height;
}

void Spike::Render(SDL_Renderer* renderer, float cameraX) {
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Pique gris foncé
    SDL_SetRenderDrawColor(renderer, 64, 64, 64, 255);
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Bordure sombre
    SDL_SetRenderDrawColor(renderer, 32, 32, 32, 255);
    SDL_RenderDrawRectF(renderer, &renderRect);
    
    // Pointes (triangles pointant vers le haut)
    SDL_SetRenderDrawColor(renderer, 96, 96, 96, 255);
    int numSpikes = static_cast<int>(mRect.w / 16.0f);
    for (int i = 0; i < numSpikes; i++) {
        float spikeX = renderRect.x + i * 16.0f;
        SDL_FPoint points[3] = {
            {spikeX + 8, renderRect.y},
            {spikeX, renderRect.y + 8},
            {spikeX + 16, renderRect.y + 8}
        };
        SDL_RenderDrawLinesF(renderer, points, 3);
    }
}

