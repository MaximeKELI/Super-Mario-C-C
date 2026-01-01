#ifndef SPIKE_H
#define SPIKE_H

#include <SDL2/SDL.h>

class Spike {
public:
    Spike(float x, float y, float width, float height);
    
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    
private:
    SDL_FRect mRect;
};

#endif

