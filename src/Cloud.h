#ifndef CLOUD_H
#define CLOUD_H

#include <SDL2/SDL.h>

class Cloud {
public:
    Cloud(float x, float y, float width, float height);
    
    void Update(float deltaTime);
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    
private:
    SDL_FRect mRect;
    float mSpeed;  // Vitesse de déplacement (parallax)
};

#endif

