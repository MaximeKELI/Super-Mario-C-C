#ifndef PARTICLE_H
#define PARTICLE_H

#include <SDL2/SDL.h>

struct Particle {
    float x, y;
    float vx, vy;
    float life;  // Durée de vie restante
    SDL_Color color;
    
    Particle(float px, float py, float pvx, float pvy, float plife, SDL_Color pcolor)
        : x(px), y(py), vx(pvx), vy(pvy), life(plife), color(pcolor) {}
};

#endif

