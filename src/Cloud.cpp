#include "Cloud.h"

Cloud::Cloud(float x, float y, float width, float height) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = width;
    mRect.h = height;
    mSpeed = 10.0f;  // Vitesse lente pour effet parallax
}

void Cloud::Update(float deltaTime) {
    // Les nuages se déplacent lentement de droite à gauche
    mRect.x -= mSpeed * deltaTime;
    
    // Réapparaître à droite quand ils sortent de l'écran
    if (mRect.x + mRect.w < 0) {
        mRect.x = 2000.0f;  // Réapparaître à droite
    }
}

void Cloud::Render(SDL_Renderer* renderer, float cameraX) {
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX * 0.3f;  // Parallax : se déplacent plus lentement que le joueur
    
    // Nuage blanc/gris clair
    SDL_SetRenderDrawColor(renderer, 240, 240, 255, 255);
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Ombres pour donner du volume
    SDL_SetRenderDrawColor(renderer, 220, 220, 240, 255);
    SDL_FRect shadow1 = {renderRect.x + 5, renderRect.y + 5, renderRect.w - 10, renderRect.h - 5};
    SDL_RenderFillRectF(renderer, &shadow1);
}

