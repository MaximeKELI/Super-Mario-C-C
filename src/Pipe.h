#ifndef PIPE_H
#define PIPE_H

#include <SDL2/SDL.h>

class Pipe {
public:
    Pipe(float x, float y, float width, float height, float targetX, float targetY);
    
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    float GetTargetX() const { return mTargetX; }
    float GetTargetY() const { return mTargetY; }
    
private:
    SDL_FRect mRect;
    float mTargetX;
    float mTargetY;
};

#endif

