#include "Block.h"

Block::Block(float x, float y, BlockType type) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = 32.0f;
    mRect.h = 32.0f;
    mType = type;
    mDestroyed = false;
    mHit = false;
    mHitAnimationTime = 0.0f;
}

void Block::Hit() {
    if (mDestroyed || mHit) return;
    
    mHit = true;
    mHitAnimationTime = 0.2f; // Animation de 0.2 secondes
    
    if (mType == BlockType::BRICK) {
        mDestroyed = true;
    }
}

void Block::Render(SDL_Renderer* renderer, float cameraX) {
    if (mDestroyed) return;
    
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Animation de hit
    if (mHit && mHitAnimationTime > 0) {
        renderRect.y -= 5.0f;
        mHitAnimationTime -= 0.016f; // Approx 60 FPS
        if (mHitAnimationTime <= 0) {
            mHit = false;
        }
    }
    
    if (mType == BlockType::QUESTION) {
        // Bloc question - jaune avec ?
        SDL_SetRenderDrawColor(renderer, 255, 215, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Bordure
        SDL_SetRenderDrawColor(renderer, 200, 150, 0, 255);
        SDL_RenderDrawRectF(renderer, &renderRect);
        
        // Point d'interrogation
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_FRect q1 = {renderRect.x + 10, renderRect.y + 6, 12, 4};
        SDL_FRect q2 = {renderRect.x + 10, renderRect.y + 10, 4, 4};
        SDL_FRect q3 = {renderRect.x + 18, renderRect.y + 10, 4, 4};
        SDL_FRect q4 = {renderRect.x + 10, renderRect.y + 18, 12, 4};
        SDL_FRect q5 = {renderRect.x + 10, renderRect.y + 22, 4, 4};
        SDL_RenderFillRectF(renderer, &q1);
        SDL_RenderFillRectF(renderer, &q2);
        SDL_RenderFillRectF(renderer, &q3);
        SDL_RenderFillRectF(renderer, &q4);
        SDL_RenderFillRectF(renderer, &q5);
    } else if (mType == BlockType::BRICK) {
        // Bloc de brique - orange/rouge
        SDL_SetRenderDrawColor(renderer, 200, 100, 50, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Lignes de brique
        SDL_SetRenderDrawColor(renderer, 150, 75, 25, 255);
        SDL_FRect line1 = {renderRect.x, renderRect.y + 10, renderRect.w, 2};
        SDL_FRect line2 = {renderRect.x, renderRect.y + 20, renderRect.w, 2};
        SDL_RenderFillRectF(renderer, &line1);
        SDL_RenderFillRectF(renderer, &line2);
    } else if (mType == BlockType::HARD) {
        // Bloc dur - gris
        SDL_SetRenderDrawColor(renderer, 128, 128, 128, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
        
        // Bordure
        SDL_SetRenderDrawColor(renderer, 64, 64, 64, 255);
        SDL_RenderDrawRectF(renderer, &renderRect);
    }
}

