#ifndef CHECKPOINT_H
#define CHECKPOINT_H

#include <SDL2/SDL.h>

class Checkpoint {
public:
    Checkpoint(float x, float y);
    
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    bool IsActivated() const { return mActivated; }
    void Activate() { mActivated = true; }
    
private:
    SDL_FRect mRect;
    bool mActivated;
    float mAnimationTime;
};

#endif

