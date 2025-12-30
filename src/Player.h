#ifndef PLAYER_H
#define PLAYER_H

#include <SDL2/SDL.h>

class Player {
public:
    Player(float x, float y);
    
    void Update(float deltaTime);
    void Render(SDL_Renderer* renderer, float cameraX);
    void HandleInput(const Uint8* keystate);
    
    SDL_FRect GetRect() const { return mRect; }
    float GetX() const { return mRect.x; }
    float GetY() const { return mRect.y; }
    float GetWidth() const { return mRect.w; }
    float GetHeight() const { return mRect.h; }
    
    void SetPosition(float x, float y);
    void SetVelocity(float vx, float vy);
    bool IsOnGround() const { return mOnGround; }
    void SetOnGround(bool onGround) { mOnGround = onGround; }
    
    bool IsDead() const { return mDead; }
    void Kill() { mDead = true; }
    void Respawn(float x, float y);
    
private:
    SDL_FRect mRect;
    float mVelocityX;
    float mVelocityY;
    bool mOnGround;
    bool mDead;
    
    static const float GRAVITY;
    static const float JUMP_FORCE;
    static const float MOVE_SPEED;
    static const float MAX_FALL_SPEED;
};

#endif

