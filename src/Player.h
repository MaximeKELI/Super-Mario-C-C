#ifndef PLAYER_H
#define PLAYER_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <vector>

struct GifFrame {
    SDL_Texture* texture;
    float delay;  // Délai en secondes
};

class Player {
public:
    Player(float x, float y, SDL_Renderer* renderer);
    ~Player();
    
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
    float GetVelocityX() const { return mVelocityX; }
    float GetVelocityY() const { return mVelocityY; }
    bool IsOnGround() const { return mOnGround; }
    void SetOnGround(bool onGround) { mOnGround = onGround; }
    
    bool IsDead() const { return mDead; }
    void Kill() { mDead = true; }
    void Respawn(float x, float y);
    
    bool IsBig() const { return mIsBig; }
    bool HasFirePower() const { return mHasFirePower; }
    bool HasFlyPower() const { return mHasFlyPower; }
    bool IsInvincible() const { return mIsInvincible; }
    bool HasCometPower() const { return mHasCometPower; }
    void CollectMushroom();
    void CollectFireFlower();
    void CollectFeather();
    void CollectStar();
    void CollectOneUp();
    void CollectComet();
    void Shrink();
    
    bool CanShoot() const { return mHasFirePower && mShootCooldown <= 0; }
    void Shoot();
    void UpdateShootCooldown(float deltaTime);
    
private:
    bool LoadAnimatedGif(SDL_Renderer* renderer, const char* path);
    bool LoadTexture(SDL_Renderer* renderer, const char* path);
    
    SDL_FRect mRect;
    std::vector<GifFrame> mGifFrames;
    int mCurrentFrame;
    float mAnimationTime;
    int mTextureWidth;
    int mTextureHeight;
    float mVelocityX;
    float mVelocityY;
    bool mOnGround;
    bool mDead;
    bool mIsBig;
    bool mHasFirePower;
    bool mHasFlyPower;
    float mShootCooldown;
    float mFlyPowerRemaining;  // Durée restante du pouvoir de vol
    bool mIsFlying;  // Indique si le joueur est en train de voler (touche espace maintenue)
    float mBaseHeight;
    bool mFacingRight;
    
    static const float GRAVITY;
    static const float JUMP_FORCE;
    static const float MOVE_SPEED;
    static const float MAX_FALL_SPEED;
    static const float SHOOT_COOLDOWN;
    static const float FLY_POWER_DURATION;  // Durée du pouvoir de vol en secondes
    static const float FLY_FORCE;  // Force vers le haut pendant le vol
};

#endif

