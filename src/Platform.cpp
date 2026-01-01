#include "Platform.h"
#include <cmath>

Platform::Platform(float x, float y, float width, float height, PlatformType type) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = width;
    mRect.h = height;
    mType = type;
    mStartX = x;
    mStartY = y;
    mDestroyed = false;
    mHitCount = 0;
    mDestroyTimer = 0.0f;
    
    if (type == PlatformType::MOVING_H) {
        mVelocityX = 50.0f;  // Vitesse horizontale
        mVelocityY = 0.0f;
        mMoveDistance = 200.0f;  // Distance de mouvement
        mCurrentDistance = 0.0f;
    } else if (type == PlatformType::MOVING_V) {
        mVelocityX = 0.0f;
        mVelocityY = 50.0f;  // Vitesse verticale
        mMoveDistance = 150.0f;
        mCurrentDistance = 0.0f;
    } else {
        mVelocityX = 0.0f;
        mVelocityY = 0.0f;
        mMoveDistance = 0.0f;
        mCurrentDistance = 0.0f;
    }
}

void Platform::Update(float deltaTime) {
    if (mDestroyed) {
        mDestroyTimer += deltaTime;
        if (mDestroyTimer > 0.5f) {
            // La plateforme disparaît complètement après 0.5s
        }
        return;
    }
    
    if (mType == PlatformType::MOVING_H) {
        // Mouvement horizontal (va-et-vient)
        mRect.x += mVelocityX * deltaTime;
        mCurrentDistance += abs(mVelocityX * deltaTime);
        
        if (mCurrentDistance >= mMoveDistance) {
            mVelocityX = -mVelocityX;  // Inverser la direction
            mCurrentDistance = 0.0f;
        }
    } else if (mType == PlatformType::MOVING_V) {
        // Mouvement vertical (va-et-vient)
        mRect.y += mVelocityY * deltaTime;
        mCurrentDistance += abs(mVelocityY * deltaTime);
        
        if (mCurrentDistance >= mMoveDistance) {
            mVelocityY = -mVelocityY;  // Inverser la direction
            mCurrentDistance = 0.0f;
        }
    }
}

void Platform::Render(SDL_Renderer* renderer, float cameraX) {
    if (mDestroyed && mDestroyTimer > 0.5f) return;  // Ne plus rendre si détruite
    
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Animation de destruction (clignotement)
    if (mDestroyed) {
        float alpha = (sin(mDestroyTimer * 20.0f) + 1.0f) * 0.5f;
        SDL_SetRenderDrawColor(renderer, static_cast<Uint8>(139 * alpha), static_cast<Uint8>(69 * alpha), static_cast<Uint8>(19 * alpha), 255);
    } else if (mType == PlatformType::DESTRUCTIBLE) {
        // Plateforme destructible - couleur différente (orange)
        SDL_SetRenderDrawColor(renderer, 200, 150, 100, 255);
    } else {
        // Plateforme normale - brun
        SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255);
    }
    
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Bordure
    SDL_SetRenderDrawColor(renderer, 101, 67, 33, 255);
    SDL_RenderDrawRectF(renderer, &renderRect);
}
