#ifndef BLOCK_H
#define BLOCK_H

#include <SDL2/SDL.h>

enum class BlockType {
    QUESTION,  // Bloc avec point d'interrogation
    BRICK,     // Bloc de brique destructible
    HARD       // Bloc indestructible
};

class Block {
public:
    Block(float x, float y, BlockType type);
    
    void Hit();
    void Render(SDL_Renderer* renderer, float cameraX);
    SDL_FRect GetRect() const { return mRect; }
    
    bool IsDestroyed() const { return mDestroyed; }
    bool IsHit() const { return mHit; }
    BlockType GetType() const { return mType; }
    
private:
    SDL_FRect mRect;
    BlockType mType;
    bool mDestroyed;
    bool mHit;
    float mHitAnimationTime;
};

#endif

