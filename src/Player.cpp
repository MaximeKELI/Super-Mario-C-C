#include "Player.h"
#include <algorithm>

const float Player::GRAVITY = 800.0f;
const float Player::JUMP_FORCE = -400.0f;
const float Player::MOVE_SPEED = 200.0f;
const float Player::MAX_FALL_SPEED = 500.0f;

Player::Player(float x, float y) {
    mRect.x = x;
    mRect.y = y;
    mRect.w = 32.0f;
    mRect.h = 32.0f;
    mVelocityX = 0.0f;
    mVelocityY = 0.0f;
    mOnGround = false;
    mDead = false;
}

void Player::Update(float deltaTime) {
    if (mDead) return;
    
    // Appliquer la gravité
    if (!mOnGround) {
        mVelocityY += GRAVITY * deltaTime;
        mVelocityY = std::min(mVelocityY, MAX_FALL_SPEED);
    }
    
    // Mettre à jour la position
    mRect.x += mVelocityX * deltaTime;
    mRect.y += mVelocityY * deltaTime;
    
    // Limiter la position horizontale
    if (mRect.x < 0) {
        mRect.x = 0;
        mVelocityX = 0;
    }
    
    // Appliquer la friction horizontale
    mVelocityX *= 0.9f;
}

void Player::Render(SDL_Renderer* renderer, float cameraX) {
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    // Dessiner Mario en rouge
    SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
    SDL_RenderFillRectF(renderer, &renderRect);
    
    // Dessiner les yeux
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    SDL_FRect eye1 = {renderRect.x + 8, renderRect.y + 8, 4, 4};
    SDL_FRect eye2 = {renderRect.x + 20, renderRect.y + 8, 4, 4};
    SDL_RenderFillRectF(renderer, &eye1);
    SDL_RenderFillRectF(renderer, &eye2);
}

void Player::HandleInput(const Uint8* keystate) {
    if (mDead) return;
    
    // Mouvement horizontal
    if (keystate[SDL_SCANCODE_LEFT] || keystate[SDL_SCANCODE_A]) {
        mVelocityX = -MOVE_SPEED;
    } else if (keystate[SDL_SCANCODE_RIGHT] || keystate[SDL_SCANCODE_D]) {
        mVelocityX = MOVE_SPEED;
    }
    
    // Saut
    if ((keystate[SDL_SCANCODE_SPACE] || keystate[SDL_SCANCODE_UP] || keystate[SDL_SCANCODE_W]) && mOnGround) {
        mVelocityY = JUMP_FORCE;
        mOnGround = false;
    }
}

void Player::SetPosition(float x, float y) {
    mRect.x = x;
    mRect.y = y;
}

void Player::SetVelocity(float vx, float vy) {
    mVelocityX = vx;
    mVelocityY = vy;
}

void Player::Respawn(float x, float y) {
    SetPosition(x, y);
    SetVelocity(0, 0);
    mDead = false;
    mOnGround = false;
}

