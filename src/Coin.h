#ifndef COIN_H
#define COIN_H

#include <SDL2/SDL.h>

class Coin {
public:
    Coin(float x, float y);
    
    void Update(float deltaTime);
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    
    bool IsCollected() const { return mCollected; }
    void Collect() { mCollected = true; }
    
private:
    SDL_FRect mRect;
    bool mCollected;
    float mAnimationTime;
    float mOriginalY;
    
    static const float BOUNCE_SPEED;
    static const float BOUNCE_HEIGHT;
};

#endif


