#ifndef PLATFORM_H
#define PLATFORM_H

#include <SDL2/SDL.h>

enum class PlatformType {
    STATIC,  // Plateforme statique normale
    MOVING_H,  // Plateforme mobile horizontale
    MOVING_V,  // Plateforme mobile verticale
    DESTRUCTIBLE  // Plateforme destructible
};

class Platform {
public:
    Platform(float x, float y, float width, float height, PlatformType type = PlatformType::STATIC);
    
    void Update(float deltaTime);
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    void SetVelocity(float vx, float vy) { mVelocityX = vx; mVelocityY = vy; }
    bool IsDestroyed() const { return mDestroyed; }
    void Hit() { mHitCount++; if (mHitCount >= 3) mDestroyed = true; }
    
private:
    SDL_FRect mRect;
    PlatformType mType;
    float mVelocityX;
    float mVelocityY;
    float mStartX;
    float mStartY;
    float mMoveDistance;
    float mCurrentDistance;
    bool mDestroyed;
    int mHitCount;
    float mDestroyTimer;
};

#endif





